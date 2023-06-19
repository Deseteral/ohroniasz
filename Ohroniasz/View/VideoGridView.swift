import SwiftUI
import AVKit

struct VideoGridView: View {
    let playlist: CamEventPlaylist

    private let playerTopLeft: AVPlayer
    private let playerTopRight: AVPlayer
    private let playerBottomLeft: AVPlayer
    private let playerBottomRight: AVPlayer

    @State private var sliderValue: Double = 0.0
    @State private var isUserDraggingSlider: Bool = false
    @State private var formattedTimeLabel: String = "00:00"
    @State private var cameraLabelOpacity = 0.0;

    private let markerCircleSize = 16.0

    init(playlist: CamEventPlaylist) {
        self.playlist = playlist

        self.playerTopLeft = playlist.front
        self.playerTopRight = playlist.back
        self.playerBottomLeft = playlist.leftRepeater
        self.playerBottomRight = playlist.rightRepeater
    }

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        VideoPlayer(player: playerTopLeft)
                        Text("Front camera").padding().opacity(cameraLabelOpacity)
                    }
                    ZStack(alignment: .topLeading) {
                        VideoPlayer(player: playerTopRight)
                        Text("Back camera").padding().opacity(cameraLabelOpacity)
                    }
                }
                HStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        VideoPlayer(player: playerBottomLeft)
                        Text("Left repeater camera").padding().opacity(cameraLabelOpacity)
                    }
                    ZStack(alignment: .topLeading) {
                        VideoPlayer(player: playerBottomRight)
                        Text("Right repeater camera").padding().opacity(cameraLabelOpacity)
                    }
                }
            }
            .onHover { isHovering in
                withAnimation {
                    self.cameraLabelOpacity = isHovering ? 1 : 0
                }
            }

            HStack {
                Button(action: togglePlayPause, label: {
                    Image(systemName: playerTopLeft.isPlaying ? "pause.fill" : "play.fill")
                })
                .buttonStyle(.bordered)
                .controlSize(.large)
                .keyboardShortcut(.space, modifiers: [])

                if playlist.event.hasMarker {
                    Button(action: seekToEventMarker, label: { Image(systemName: "goforward") })
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                }

                Text(self.formattedTimeLabel)
                    .monospacedDigit()

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        if let incidentTimeOffset = playlist.event.incidentTimeOffset {
                            Circle()
                                .fill(.red)
                                .frame(width: markerCircleSize, height: markerCircleSize)
                                .padding(.leading, (incidentTimeOffset / playlist.duration) * (geometry.size.width - markerCircleSize))
                        }
                        
                        Slider(value: $sliderValue, in: 0...playlist.duration) { editing in self.isUserDraggingSlider = editing }
                            .tint(.accentColor)
                    }
                }
                .frame(height: 18)

                Text(VideoGridView.formatTimeLabel(seconds: playlist.duration))
                    .monospacedDigit()
            }
            .padding()
        }
        .onAppear {
            actOnAllPlayers { player in
                player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 60000), queue: nil, using: playerTimeChanged)
            }
        }
        .onChange(of: sliderValue, perform: sliderValueChanged)
    }

    private func playerTimeChanged(to time: CMTime) {
        guard !isUserDraggingSlider else {
            return
        }
        self.sliderValue = time.seconds
    }

    private func sliderValueChanged(to newValue: Double) {
        self.formattedTimeLabel = VideoGridView.formatTimeLabel(seconds: newValue)

        if isUserDraggingSlider {
            seek(to: newValue)
        }
    }

    private func seek(to seconds: Double) {
        actOnAllPlayers { $0.pause() }

        let time =  CMTime(seconds: seconds, preferredTimescale: 60000)
        actOnAllPlayers { player in
            player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }

    private func togglePlayPause() {
        if playerTopLeft.isPlaying {
            actOnAllPlayers { $0.pause() }
        } else {
            actOnAllPlayers { $0.play() }
        }
    }

    private func seekToEventMarker() {
        if let incidentTimeOffset = playlist.event.incidentTimeOffset {
            seek(to: incidentTimeOffset)
        }
    }

    private func actOnAllPlayers(callback: (AVPlayer) -> ()) {
        callback(playerTopLeft)
        callback(playerTopRight)
        callback(playerBottomLeft)
        callback(playerBottomRight)
    }

    private static func formatTimeLabel(seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional

        return formatter.string(from: TimeInterval(seconds))!
    }
}

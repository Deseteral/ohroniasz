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
                    VideoPlayer(player: playerTopLeft)
                    VideoPlayer(player: playerTopRight)
                }
                HStack(spacing: 0) {
                    VideoPlayer(player: playerBottomLeft)
                    VideoPlayer(player: playerBottomRight)
                }
            }
            
            HStack {
                Button(action: togglePlayPause, label: { Image(systemName: "play.fill") })
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                
                Slider(value: $sliderValue, in: 0...playlist.duration) { editing in self.isUserDraggingSlider = editing }
                    .tint(.accentColor)

                Text(formattedTimeLabel)
            }
            .padding()
        }
        .onAppear {
            actOnAllPlayers { player in
                player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 60000), queue: nil) { time in
                    guard !isUserDraggingSlider else { return }
                    self.sliderValue = time.seconds
                }
            }
        }
        .onChange(of: sliderValue, perform: sliderChanged)
    }

    private func sliderChanged(to newValue: Double) {
        guard isUserDraggingSlider else {
            return
        }
        
        actOnAllPlayers { $0.pause() }

        let time =  CMTime(seconds: newValue, preferredTimescale: 60000)
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
    
    private func actOnAllPlayers(callback: (AVPlayer) -> ()) {
        callback(playerTopLeft)
        callback(playerTopRight)
        callback(playerBottomLeft)
        callback(playerBottomRight)
    }
}

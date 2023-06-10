import SwiftUI
import AVKit

struct VideoGridView: View {
    let playlist: CamEventPlaylist
    
    private let playerTopLeft: AVPlayer
    private let playerTopRight: AVPlayer
    private let playerBottomLeft: AVPlayer
    private let playerBottomRight: AVPlayer
    
    @State private var sliderValue = 0.0
    @State private var isUserDraggingSlider = false
    
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
                    .onChange(of: sliderValue, perform: sliderChanged)
            }
            .padding()
        }
    }

    private func sliderChanged(to newValue: Double) {
        if (!isUserDraggingSlider) {
            return
        }
        
        actOnCurrentPlayers { player in player.pause() }

        let time =  CMTime(seconds: newValue, preferredTimescale: 60000)
        actOnCurrentPlayers { player in
            player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }
    
    private func togglePlayPause() {
        if playerTopLeft.isPlaying {
            actOnCurrentPlayers { player in player.pause() }
        } else {
            actOnCurrentPlayers { player in player.play() }
        }
    }
    
    private func actOnCurrentPlayers(callback: (AVPlayer) -> ()) {
        callback(playerTopLeft)
        callback(playerTopRight)
        callback(playerBottomLeft)
        callback(playerBottomRight)
    }
}

// TODO: Extract from here.
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

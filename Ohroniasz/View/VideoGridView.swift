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
    @State private var wholeDuration = 0.0
    
    init(playlist: CamEventPlaylist) {
        self.playlist = playlist

        let avItemFront = VideoGridView.concatVideoClips(from: playlist.front)
        let avItemBack = VideoGridView.concatVideoClips(from: playlist.back)
        let avItemLeftRepeater = VideoGridView.concatVideoClips(from: playlist.leftRepeater)
        let avItemRightRepeater = VideoGridView.concatVideoClips(from: playlist.rightRepeater)

        wholeDuration = max(
            avItemFront.duration.seconds,
            avItemBack.duration.seconds,
            avItemLeftRepeater.duration.seconds,
            avItemRightRepeater.duration.seconds
        )

        playerTopLeft = AVPlayer(playerItem: avItemFront)
        playerTopRight = AVPlayer(playerItem: avItemBack)
        playerBottomLeft = AVPlayer(playerItem: avItemLeftRepeater)
        playerBottomRight = AVPlayer(playerItem: avItemRightRepeater)
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
                
                Slider(value: $sliderValue, in: 0...wholeDuration) { editing in self.isUserDraggingSlider = editing }
                    .tint(.accentColor)
                    .onChange(of: sliderValue, perform: sliderChanged)
            }
            .padding()
        }
    }
    
    private static func concatVideoClips(from clipPaths: [String]) -> AVPlayerItem {
        let movie = AVMutableComposition()
        do {
            let videoTrack = movie.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            var accumulatedDuration: Double = 0.0
            
            for clipPath in clipPaths {
                let clipAsset = AVURLAsset(url: URL(fileURLWithPath: clipPath))
                let clipVideoTrack = clipAsset.tracks(withMediaType: .video).first!
                let range = CMTimeRangeMake(start: CMTime.zero, duration: clipAsset.duration)
                try videoTrack?.insertTimeRange(range, of: clipVideoTrack, at: CMTime(seconds: accumulatedDuration, preferredTimescale: 60000))
                accumulatedDuration += clipAsset.duration.seconds
            }
        } catch {
            print("Cannot bla bla")
        }
        
        return AVPlayerItem(asset: movie)
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

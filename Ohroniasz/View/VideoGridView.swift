import SwiftUI
import AVKit

struct VideoGridView: View {
    private let playerTopLeft = AVPlayer(url: URL(fileURLWithPath: "/tmp/not-existing-path.mp4"))
    private let playerTopRight = AVPlayer(url: URL(fileURLWithPath: "/tmp/not-existing-path.mp4"))
    private let playerBottomLeft = AVPlayer(url: URL(fileURLWithPath: "/tmp/not-existing-path.mp4"))
    private let playerBottomRight = AVPlayer(url: URL(fileURLWithPath: "/tmp/not-existing-path.mp4"))
    
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
                
                Slider(value: .constant(0.1))
                    .tint(Color.pink)
            }
            .padding()
        }
    }
    
    private func togglePlayPause() {
        print("play")
    }
}

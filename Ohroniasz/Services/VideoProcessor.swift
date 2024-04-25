import AVKit

fileprivate let logger = makeLogger(for: "VideoProcessor")

class VideoProcessor {
    static func loadEventPlaylist(event: CamEvent) async -> CamEventPlaylist? {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: event.path) else {
            logger.error("Failed to read contents of '\(event.path, privacy: .public)' directory.")
            return nil
        }

        let paths = files
            .map { fileName in event.path + "/" + fileName }
            .sorted()

        async let front = concatVideoClips(from: paths.filter { filePath in filePath.hasSuffix("-front.mp4") })
        async let back = concatVideoClips(from: paths.filter { filePath in filePath.hasSuffix("-back.mp4") })
        async let leftRepeater = concatVideoClips(from: paths.filter { filePath in filePath.hasSuffix("-left_repeater.mp4") })
        async let rightRepeater = concatVideoClips(from: paths.filter { filePath in filePath.hasSuffix("-right_repeater.mp4") })

        let duration = await max(front.duration.seconds, back.duration.seconds, leftRepeater.duration.seconds, rightRepeater.duration.seconds)

        return await CamEventPlaylist(
            front: AVPlayer(playerItem: front),
            back: AVPlayer(playerItem: back),
            leftRepeater: AVPlayer(playerItem: leftRepeater),
            rightRepeater: AVPlayer(playerItem: rightRepeater),
            duration: duration,
            event: event
        )
    }

    // TODO: Do actual error handling.
    private static func concatVideoClips(from clipPaths: [String]) async -> AVPlayerItem {
        let clip = AVMutableComposition()

        let videoTrack = clip.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        var accumulatedDuration: Double = 0.0

        for clipPath in clipPaths {
            let clipAsset = AVURLAsset(url: URL(fileURLWithPath: clipPath))
            let clipVideoTrack = try? await clipAsset.loadTracks(withMediaType: .video).first!
            let clipDuration = try? await clipAsset.load(.duration)
            let range = CMTimeRangeMake(start: CMTime.zero, duration: clipDuration!)
            try? videoTrack?.insertTimeRange(range, of: clipVideoTrack!, at: CMTime(seconds: accumulatedDuration, preferredTimescale: 60000))
            accumulatedDuration += clipDuration!.seconds
        }

        return AVPlayerItem(asset: clip)
    }
}

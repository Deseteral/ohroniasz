import Foundation
import AVKit

struct CamEvent: Identifiable {
    let id: String
    let date: Date
    let type: CamEventType
    let path: String
}

enum CamEventType: String {
    case savedClip
    case sentryClip
}

struct CamEventPlaylist {
    let front: AVPlayer
    let back: AVPlayer
    let leftRepeater: AVPlayer
    let rightRepeater: AVPlayer
    
    let duration: Double
}

struct CamEventMetadata: Codable {
    let timestamp: Date
    let city: String
}

class LibraryManager {
    static func scanLibrary(libraryPath: String) -> [CamEvent] {
        return (
            scanEventsFolder(eventsFolderPath: (libraryPath + "/SentryClips"), type: .sentryClip) +
            scanEventsFolder(eventsFolderPath: (libraryPath + "/SavedClips"), type: .savedClip)
        ).sorted { a, b in
            a.date.compare(b.date) == .orderedDescending
        }
    }

    private static func scanEventsFolder(eventsFolderPath: String, type: CamEventType) -> [CamEvent] {
        let dateFolderRegex = /\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}/

        let items = try? FileManager.default
            .contentsOfDirectory(atPath: eventsFolderPath)
            .filter { $0.wholeMatch(of: dateFolderRegex) != nil }

        guard let items else {
            print("Failed to scan events from '\(eventsFolderPath)' folder.")
            return []
        }

        var events: [CamEvent] = []

        for folderName in items {
            let path = eventsFolderPath + "/" + folderName
            let metadataPath = path + "/" + "event.json"

            guard let jsonData = try? String(contentsOfFile: metadataPath).data(using: .utf8) else {
                continue
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

            guard let metadata = try? jsonDecoder.decode(CamEventMetadata.self, from: jsonData) else {
                continue
            }

            let event = CamEvent(
                id: path,
                date: metadata.timestamp,
                type: type,
                path: path
            )

            events.append(event)
        }

        return events
    }
    
    static func loadEventPlaylist(eventPath: String) async -> CamEventPlaylist? {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: eventPath) else {
            print("Failed to read contents of '\(eventPath)' directory.")
            return nil
        }

        let paths = files
            .map { fileName in eventPath + "/" + fileName }
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
            duration: duration
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

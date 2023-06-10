import Foundation
import AVKit

struct CamEvent: Identifiable {
    let id: String
    let date: Date
    let kind: CamEventKind
    let path: String
}

enum CamEventKind: String {
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

class LibraryManager {
    static func scanLibrary(libraryPath: String) -> [CamEvent] {
        var events: [CamEvent] = []
        
        // TODO: Find a way to make this paths better than with concat
        let sentryClipsPath = libraryPath + "/SentryClips"
        let savedClipsPath = libraryPath + "/SavedClips"
        
        let dateFolderRegex = /\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}/
        
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        
        do {
            let sentryItems = try FileManager.default.contentsOfDirectory(atPath: sentryClipsPath)
                .filter { it in it.wholeMatch(of: dateFolderRegex) != nil }

            for folderName in sentryItems {
                let path = sentryClipsPath + "/" + folderName
                if let dt = dtFormatter.date(from: folderName) {
                    let event = CamEvent(
                        id: path,
                        date: dt, // TODO: Fix wrong date - load it from event.json metadata
                        kind: .sentryClip,
                        path: path
                    )
                    events.append(event)
                }
            }
        } catch {
            print("Failed to read SentryClips directory")
        }
        
        do {
            let savedItems = try FileManager.default.contentsOfDirectory(atPath: savedClipsPath)
                .filter { it in it.wholeMatch(of: dateFolderRegex) != nil }

            for folderName in savedItems {
                let path = savedClipsPath + "/" + folderName
                if let dt = dtFormatter.date(from: folderName) {
                    let event = CamEvent(
                        id: path,
                        date: dt, // TODO: Fix wrong date - load it from event.json metadata
                        kind: .savedClip,
                        path: path
                    )
                    events.append(event)
                }
            }
        } catch {
            print("Failed to read SavedClips directory")
        }
        
        events.sort { a, b in
            a.date.compare(b.date) == .orderedDescending
        }
        
        return events
    }
    
    static func loadEventPlaylist(eventPath: String) async -> CamEventPlaylist? {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: eventPath) else {
            print("Failed to read contents of \(eventPath) directory.")
            return nil
        }

        let paths = files
            .map { fileName in eventPath + "/" + fileName }
            .sorted()
            
        let front = await concatVideoClips(from: paths.filter { filePath in filePath.hasSuffix("-front.mp4") })
        let back = await concatVideoClips(from: paths.filter { filePath in filePath.hasSuffix("-back.mp4") })
        let leftRepeater = await concatVideoClips(from: paths.filter { filePath in filePath.hasSuffix("-left_repeater.mp4") })
        let rightRepeater = await concatVideoClips(from: paths.filter { filePath in filePath.hasSuffix("-right_repeater.mp4") })

        let duration = max(front.duration.seconds, back.duration.seconds, leftRepeater.duration.seconds, rightRepeater.duration.seconds)

        return CamEventPlaylist(
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

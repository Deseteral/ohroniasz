import Foundation
import AVKit

struct CamEvent: Identifiable, Equatable {
    let id: String
    let date: Date
    let type: CamEventType
    let path: String
    let location: CamEventLocation?

    static func == (lhs: CamEvent, rhs: CamEvent) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CamEventLocation: Equatable {
    let city: String
    let lat: Double
    let lon: Double

    init(metadata: CamEventMetadata) {
        self.city = metadata.city
        self.lat = Double(metadata.est_lat)!
        self.lon = Double(metadata.est_lon)!
    }
}

enum CamEventType: String {
    case savedClip
    case sentryClip
    case recentClip
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
    let est_lat: String
    let est_lon: String
}

class LibraryScanner {
    static func scanLibrary(atPath libraryPath: String) -> [CamEvent] {
        return (
            scanClipsFolder(atPath: (libraryPath + "/SentryClips"), eventType: .sentryClip) +
            scanClipsFolder(atPath: (libraryPath + "/SavedClips"), eventType: .savedClip) +
            scanRecentClipsFolder(atPath: (libraryPath + "/RecentClips"))
        ).sorted { a, b in
            a.date.compare(b.date) == .orderedDescending
        }
    }

    private static func scanClipsFolder(atPath clipsFolderPath: String, eventType: CamEventType) -> [CamEvent] {
        guard FileManager.default.directoryExists(atPath: clipsFolderPath) else {
            return []
        }

        let dateFolderRegex = /\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}/

        let items = try? FileManager.default
            .contentsOfDirectory(atPath: clipsFolderPath)
            .filter { $0.wholeMatch(of: dateFolderRegex) != nil }

        guard let items else {
            return []
        }

        var events: [CamEvent] = []

        for folderName in items {
            let path = clipsFolderPath + "/" + folderName
            if let event = readEvent(eventPath: path, eventType: eventType) {
                events.append(event)
            }
        }

        return events
    }

    private static func scanRecentClipsFolder(atPath clipsFolderPath: String) -> [CamEvent] {
        guard FileManager.default.directoryExists(atPath: clipsFolderPath) else {
            return []
        }

        guard let date = getDateFromClipFileName(clipsFolderPath: clipsFolderPath) else {
            return []
        }

        return [CamEvent(id: clipsFolderPath, date: date, type: .recentClip, path: clipsFolderPath, location: nil)]
    }

    private static func readEvent(eventPath: String, eventType: CamEventType) -> CamEvent? {
        let metadata = readEventMetadata(eventPath: eventPath)

        let date: Date;
        let location: CamEventLocation?;

        if let metadata {
            date = metadata.timestamp
            location = CamEventLocation(metadata: metadata)
        } else {
            guard let dateFromFile = getDateFromClipFileName(clipsFolderPath: eventPath) else {
                return nil
            }

            date = dateFromFile
            location = nil
        }

        return CamEvent(id: eventPath, date: date, type: eventType, path: eventPath, location: location)
    }

    private static func readEventMetadata(eventPath: String) -> CamEventMetadata? {
        let metadataPath = eventPath + "/" + "event.json"

        guard let jsonData = try? String(contentsOfFile: metadataPath).data(using: .utf8) else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

        guard let metadata = try? jsonDecoder.decode(CamEventMetadata.self, from: jsonData) else {
            return nil
        }

        return metadata
    }

    // TODO: I hate this function.
    private static func getDateFromClipFileName(clipsFolderPath: String) -> Date? {
        let clipFileRegex = /\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}-back\.mp4/

        let items = try? FileManager.default
            .contentsOfDirectory(atPath: clipsFolderPath)
            .filter { $0.wholeMatch(of: clipFileRegex) != nil }

        guard var firstItem = items?.first else {
            return nil
        }

        firstItem.replace("-back.mp4", with: "")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"

        return dateFormatter.date(from: firstItem)
    }
}

import Foundation
import AVKit

struct CamEvent: Identifiable {
    let id: String
    let date: Date
    let type: CamEventType
    let path: String
    let location: CamEventLocation
}

struct CamEventLocation {
    let city: String
    let lat: Double
    let lon: Double
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
    let est_lat: String
    let est_lon: String
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
                path: path,
                location: CamEventLocation(
                    city: metadata.city,
                    lat: Double(metadata.est_lat)!,
                    lon: Double(metadata.est_lon)!
                )
            )

            events.append(event)
        }

        return events
    }
}

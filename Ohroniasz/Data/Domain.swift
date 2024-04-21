import Foundation
import SwiftUI
import AVKit

struct CamEvent: Identifiable, Equatable, Codable {
    let id: String
    let date: Date
    let type: CamEventType
    let path: String
    let location: CamEventLocation?
    let incidentTimeOffset: Double?

    var description: String = ""
    var isFavorite: Bool = false

    static func == (lhs: CamEvent, rhs: CamEvent) -> Bool {
        return lhs.id == rhs.id
    }

    var hasMarker: Bool {
        return incidentTimeOffset != nil
    }
}

struct CamEventLocation: Equatable, Codable {
    let city: String
    let lat: Double
    let lon: Double

    init(metadata: CamEventMetadata) {
        self.city = metadata.city
        self.lat = Double(metadata.est_lat)!
        self.lon = Double(metadata.est_lon)!
    }
}

enum CamEventType: String, Codable {
    case savedClip
    case sentryClip
    case recentClip

    var systemImage: String {
        switch self {
            case .savedClip:
                return "externaldrive.fill"
            case .sentryClip:
                return "circle.fill"
            case .recentClip:
                return "timer"
        }
    }

    var color: Color {
        switch self {
            case .savedClip:
                return .blue
            case .sentryClip:
                return .red
            case .recentClip:
                return .yellow
        }
    }

    var helpText: String {
        switch self {
            case .savedClip:
                return "Saved clip"
            case .sentryClip:
                return "Sentry clip"
            case .recentClip:
                return "Recent drive"
        }
    }
}

struct CamEventPlaylist {
    let front: AVPlayer
    let back: AVPlayer
    let leftRepeater: AVPlayer
    let rightRepeater: AVPlayer

    let duration: Double
    let event: CamEvent
}

struct CamEventMetadata: Codable {
    let timestamp: Date
    let city: String
    let est_lat: String
    let est_lon: String
}

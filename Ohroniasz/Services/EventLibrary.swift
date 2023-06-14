import Foundation
import SwiftUI

class EventLibrary: ObservableObject {
    @Published var events: [CamEvent] = []

    var hasEventsLoaded: Bool {
        return events.count > 0
    }

    func filterEvents(type: EventFilter) -> [CamEvent] {
        switch type {
            case .all:
                return events
            case .sentry:
                return events.filter { $0.type == .sentryClip }
            case .saved:
                return events.filter { $0.type == .savedClip }
        }
    }

    func findEvent(by eventId: CamEvent.ID) -> CamEvent? {
        return events.first { $0.id == eventId }
    }
}

enum EventFilter: String, CaseIterable {
    case all = "All clips"
    case sentry = "Sentry"
    case saved = "Saved clips"

    var systemIcon: String {
        switch self {
            case .all: return "folder"
            case .sentry: return "circle"
            case .saved: return "star"
        }
    }
}

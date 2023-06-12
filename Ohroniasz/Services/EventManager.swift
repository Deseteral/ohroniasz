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

class EventManager {
    static func filterEvents(events: [CamEvent], filter: EventFilter) -> [CamEvent] {
        switch filter {
            case .all:
                return events
            case .sentry:
                return events.filter { $0.type == .sentryClip }
            case .saved:
                return events.filter { $0.type == .savedClip }
        }
    }

    static func findEvent(by eventId: CamEvent.ID, events: [CamEvent]) -> CamEvent? {
        return events.first { $0.id == eventId }
    }
}

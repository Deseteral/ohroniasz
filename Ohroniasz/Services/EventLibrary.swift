import Foundation
import SwiftUI

class EventLibrary: ObservableObject {
    var libraryPath: String = ""

    @Published var events: [CamEvent] = []

    var hasEventsLoaded: Bool {
        return events.count > 0
    }

    func loadEvents(libraryPath: String, events: [CamEvent]) {
        self.libraryPath = libraryPath
        self.events = events
        readLibraryData()
    }

    func filterEvents(type: EventFilter) -> [CamEvent] {
        switch type {
            case .all:
                return events
            case .sentry:
                return events.filter { $0.type == .sentryClip }
            case .saved:
                return events.filter { $0.type == .savedClip }
            case .favorites:
                return []
        }
    }

    func findEvent(by eventId: CamEvent.ID) -> CamEvent? {
        return events.first { $0.id == eventId }
    }

    func saveLibraryData() {
        let data = LibraryData()

        for event in events {
            guard !event.description.isEmpty else { continue }
            data.descriptions[event.id] = event.description
        }

        data.saveToDisk(libraryPath: libraryPath)
    }

    private func readLibraryData() {
        let data = LibraryData.readFromDisk(libraryPath: libraryPath)

        guard let data else {
            LibraryData.saveDefaultToDisk(libraryPath: libraryPath)
            return
        }

        for description in data.descriptions {
            guard let idx = events.firstIndex(where: { $0.id == description.key }) else { continue }
            events[idx].description = description.value
        }
    }
}

enum EventFilter: String, CaseIterable {
    case all = "All clips"
    case sentry = "Sentry events"
    case saved = "Saved clips"
    case favorites = "Favorite clips"

    var systemIcon: String {
        switch self {
            case .all: return "folder"
            case .sentry: return "circle"
            case .saved: return "externaldrive"
            case .favorites: return "star"
        }
    }
}

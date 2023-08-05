import Foundation
import SwiftUI

class OrganizerViewModel: ObservableObject {
    var libraryPath: String = ""

    @Published var events: [CamEvent] = []
    @Published var eventFilter: EventFilter = .all
    @Published var selectedEventId: CamEvent.ID? = nil
    @Published var searchText: String = ""

    var displayEvents: [CamEvent] {
        return getDisplayEvents()
    }

    var selectedEvent: CamEvent? {
        get {
            guard let id = self.selectedEventId else { return nil }
            return getEvent(by: id)
        }
        set { self.selectedEventId = newValue?.id }
    }

    var hasEventsLoaded: Bool {
        return events.count > 0
    }

    var hasSelectedEvent: Bool {
        return selectedEventId != nil
    }

    var isSelectedClipTypeRecent: Bool {
        guard let selectedEvent = selectedEvent else { return false }
        return selectedEvent.type == .recentClip
    }

    func loadEvents(from libraryPath: String) {
        self.libraryPath = libraryPath
        self.events = LibraryScanner.scanLibrary(atPath: libraryPath)
        readLibraryData()
    }

    private func getDisplayEvents() -> [CamEvent] {
        let eventsWithFilter = switch self.eventFilter {
            case .all:
                events
            case .sentry:
                events.filter { $0.type == .sentryClip }
            case .saved:
                events.filter { $0.type == .savedClip }
            case .favorites:
                events.filter { $0.isFavorite }
        }

        let eventsWithFilterAndSearch = if searchText.isEmpty {
            eventsWithFilter
        } else {
            eventsWithFilter.filter { $0.description.lowercased().contains(searchText.lowercased()) }
        }

        return eventsWithFilterAndSearch
    }

    func getEvent(by eventId: CamEvent.ID) -> CamEvent? {
        return events.first { $0.id == eventId }
    }

    func markAsFavorite(event: CamEvent) {
        guard let idx = events.firstIndex(of: event) else { return }        
        events[idx].isFavorite.toggle()
        saveLibraryData()
    }

    func removeEvent(event: CamEvent) {
        if selectedEventId == event.id {
            selectedEventId = nil
        }

        if let idx = events.firstIndex(of: event) {
            events.remove(at: idx)
        }

        let url = URL(filePath: event.path, directoryHint: .isDirectory)

        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            // TODO: Maybe show some message to the user?
            return
        }
    }

    func saveLibraryData() {
        let data = LibraryData()

        for event in events {
            if !event.description.isEmpty {
                data.descriptions[event.id] = event.description
            }

            if event.isFavorite {
                data.favorites.append(event.id)
            }
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

        for (idx, event) in events.enumerated() {
            events[idx].isFavorite = data.favorites.contains { $0 == event.id }
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

import Foundation
import SwiftUI

class EventLibrary: ObservableObject {
    var libraryPath: String = ""

    @Published var events: [CamEvent] = []

    var hasEventsLoaded: Bool {
        return events.count > 0
    }

    private var dataFilePath: String {
        return libraryPath + "/" + "ohroniasz.json"
    }

    func loadEvents(libraryPath: String, events: [CamEvent]) {
        self.libraryPath = libraryPath
        self.events = events
        readLibraryDataFromDisk()
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

    func writeLibraryDataToDisk() {
        var data = LibraryData()

        for event in events {
            guard !event.description.isEmpty else { continue }
            data.descriptions[event.id] = event.description
        }

        do {
            let jsonData = try JSONEncoder().encode(data)
            let json = String(data: jsonData, encoding: .utf8)
            try json?.write(toFile: dataFilePath, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }

    private func readLibraryDataFromDisk() {
        do {
            let jsonData = try String(contentsOfFile: dataFilePath).data(using: .utf8)
            let data = try JSONDecoder().decode(LibraryData.self, from: jsonData!)

            for description in data.descriptions {
                guard let idx = events.firstIndex(where: { $0.id == description.key }) else { continue }
                events[idx].description = description.value
            }
        } catch {
            print(error)
        }
    }
}

fileprivate struct LibraryData: Codable {
    var descriptions: [CamEvent.ID: String] = [:]
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

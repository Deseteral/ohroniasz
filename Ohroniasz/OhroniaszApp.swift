import SwiftUI

enum EventFilter: String, CaseIterable {
    case all = "All clips"
    case sentry = "Sentry"
    case saved = "Saved clips"
    case sentryAndSaved = "Sentry & saved"
    
    var systemIcon: String {
        switch(self) {
        case .all: return "folder"
        case .sentry: return "circle"
        case .saved: return "star"
        case .sentryAndSaved: return "star.circle"
        }
    }
}

@main
struct OhroniaszApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var eventFilter: EventFilter = .all
    @State private var events: [CamEvent] = []
    @State private var selectedEvent: CamEvent.ID? = nil
    @State private var selectedPlaylist: CamEventPlaylist? = nil

    var body: some Scene {
        WindowGroup {
            Group {
                if events.count > 0 {
                    NavigationSplitView {
                        List(selection: $eventFilter) {
                            ForEach(EventFilter.allCases, id: \.rawValue) { filter in
                                NavigationLink(value: filter) {
                                    HStack {
                                        Image(systemName: filter.systemIcon)
                                            .foregroundColor(.accentColor)
                                            .frame(width: 18)
                                        Text(filter.rawValue)
                                    }
                                }
                            }
                        }
                    } content: {
                        EventListView(events: events, selectedEvent: $selectedEvent)
                    } detail: {
                        if selectedEvent == nil {
                            Text("Select event from the list")
                        } else {
                            if let selectedPlaylist = selectedPlaylist {
                                VideoGridView(playlist: selectedPlaylist)
                            } else {
                                ProgressView()
                            }
                        }
                    }
                    .onChange(of: self.eventFilter) { _ in
                        self.selectedEvent = nil
                    }
                    .onChange(of: self.selectedEvent) { newValue in
                        if newValue == nil { return }

                        let event = events.first { e in e.id == newValue }
                        self.selectedPlaylist = LibraryManager.loadEventPlaylist(eventPath: event!.path)
                    }
                } else {
                    WelcomeView() { libraryPath in
                        self.events = LibraryManager.scanLibrary(libraryPath: libraryPath)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

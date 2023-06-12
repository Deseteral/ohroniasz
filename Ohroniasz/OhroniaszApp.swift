import SwiftUI

enum EventFilter: String, CaseIterable {
    case all = "All clips"
    case sentry = "Sentry"
    case saved = "Saved clips"
    case sentryAndSaved = "Sentry & saved"
    
    var systemIcon: String {
        switch self {
            case .all: return "folder"
            case .sentry: return "circle"
            case .saved: return "star"
            case .sentryAndSaved: return "star.circle"
        }
    }
}

enum PlaylistLoadingState {
    case notSelected
    case loading
    case error
    case loaded(CamEventPlaylist)
}

@main
struct OhroniaszApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var events: [CamEvent] = []

    @State private var eventFilter: EventFilter = .all
    @State private var selectedEvent: CamEvent.ID? = nil
    @State private var selectedPlaylist: PlaylistLoadingState = .notSelected

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
                        switch selectedPlaylist {
                            case .notSelected:
                                Text("Select event from the list")
                            case .loading:
                                ProgressView()
                            case .error:
                                Text("Something went wrong")
                            case .loaded(let playlist):
                                VideoGridView(playlist: playlist)
                        }
                    }
                    .onChange(of: self.eventFilter) { _ in
                        self.selectedEvent = nil
                    }
                    .onChange(of: self.selectedEvent) { newValue in
                        guard let newValue else {
                            self.selectedPlaylist = .notSelected
                            return
                        }

                        guard let event = (events.first { $0.id == newValue }) else {
                            self.selectedPlaylist = .error
                            return
                        }

                        self.selectedPlaylist = .loading

                        Task {
                            if let playlist = await VideoProcessor.loadEventPlaylist(eventPath: event.path) {
                                self.selectedPlaylist = .loaded(playlist)
                            }
                        }
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

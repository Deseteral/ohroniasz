import SwiftUI

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
    @State private var displayEvents: [CamEvent] = []

    @State private var eventFilter: EventFilter = .all
    @State private var selectedEventId: CamEvent.ID? = nil
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
                        EventListView(events: displayEvents, selectedEvent: $selectedEventId)
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
                        self.selectedEventId = nil
                    }
                    .onChange(of: self.selectedEventId) { newValue in
                        guard let newValue else {
                            self.selectedPlaylist = .notSelected
                            return
                        }

                        guard let selectedEvent = EventManager.findEvent(by: newValue, events: events) else {
                            self.selectedPlaylist = .error
                            return
                        }

                        self.selectedPlaylist = .loading

                        Task {
                            if let playlist = await VideoProcessor.loadEventPlaylist(eventPath: selectedEvent.path) {
                                self.selectedPlaylist = .loaded(playlist)
                            }
                        }
                    }
                    .onChange(of: eventFilter) { newValue in
                        self.displayEvents = EventManager.filterEvents(events: events, filter: newValue)
                    }
                } else {
                    WelcomeView() { libraryPath in
                        self.events = LibraryScanner.scanLibrary(atPath: libraryPath)
                        self.displayEvents = EventManager.filterEvents(events: events, filter: eventFilter)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

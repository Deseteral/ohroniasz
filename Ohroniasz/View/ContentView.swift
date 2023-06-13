import SwiftUI

enum PlaylistLoadingState {
    case notSelected
    case loading
    case error
    case loaded(CamEventPlaylist)
}

struct ContentView: View {
    let events: [CamEvent]

    @State private var eventFilter: EventFilter = .all
    @State private var selectedEventId: CamEvent.ID? = nil
    @State private var selectedPlaylist: PlaylistLoadingState = .notSelected

    var body: some View {
        NavigationSplitView {
            SidebarView(eventFilter: $eventFilter)
        } content: {
            EventListView(
                events: events,
                eventFilter: eventFilter,
                selectedEvent: $selectedEventId
            )
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
    }
}

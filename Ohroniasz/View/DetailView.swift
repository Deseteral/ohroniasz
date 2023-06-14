import SwiftUI

fileprivate enum PlaylistLoadingState {
    case notSelected
    case loading
    case error
    case loaded(CamEventPlaylist)
}

struct DetailView: View {
    let selectedEventId: CamEvent.ID?

    @EnvironmentObject private var eventLibrary: EventLibrary

    @State private var selectedPlaylist: PlaylistLoadingState = .notSelected

    var body: some View {
        Group {
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
        .onChange(of: self.selectedEventId) { nextSelectedEventId in
            guard let nextSelectedEventId else {
                self.selectedPlaylist = .notSelected
                return
            }

            guard let selectedEvent = eventLibrary.findEvent(by: nextSelectedEventId) else {
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

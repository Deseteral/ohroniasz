import SwiftUI

fileprivate enum PlaylistLoadingState {
    case notSelected
    case loading
    case loaded(CamEventPlaylist)
}

struct DetailView: View {
    let selectedEvent: CamEvent?

    @EnvironmentObject private var eventLibrary: EventLibrary

    @State private var selectedPlaylist: PlaylistLoadingState = .notSelected

    var body: some View {
        Group {
            switch selectedPlaylist {
                case .notSelected:
                    Text("Select event from the list")
                case .loading:
                    ProgressView()
                case .loaded(let playlist):
                    VideoGridView(playlist: playlist, event: selectedEvent!)
            }
        }
        .onChange(of: self.selectedEvent) { nextSelectedEvent in
            guard let nextSelectedEvent else {
                self.selectedPlaylist = .notSelected
                return
            }

            self.selectedPlaylist = .loading

            Task {
                if let playlist = await VideoProcessor.loadEventPlaylist(eventPath: nextSelectedEvent.path) {
                    self.selectedPlaylist = .loaded(playlist)
                }
            }
        }
    }
}

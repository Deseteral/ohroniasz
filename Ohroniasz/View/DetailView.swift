import SwiftUI

fileprivate enum PlaylistLoadingState {
    case notSelected
    case loading
    case loaded(CamEventPlaylist)
}

struct DetailView: View {
    @State private var selectedPlaylist: PlaylistLoadingState = .notSelected

    @EnvironmentObject private var organizerViewModel: OrganizerViewModel

    var body: some View {
        Group {
            switch selectedPlaylist {
                case .notSelected:
                    Text("Select event from the list")
                case .loading:
                    ProgressView()
                case .loaded(let playlist):
                    VideoGridView(playlist: playlist)
            }
        }
        .onChange(of: organizerViewModel.selectedEvent) { _, nextSelectedEvent in
            guard let nextSelectedEvent else {
                self.selectedPlaylist = .notSelected
                return
            }

            self.selectedPlaylist = .loading

            Task {
                if let playlist = await VideoProcessor.loadEventPlaylist(event: nextSelectedEvent) {
                    self.selectedPlaylist = .loaded(playlist)
                }
            }
        }
    }
}

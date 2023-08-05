import SwiftUI

struct ContentToolbar: ToolbarContent {
    @EnvironmentObject private var organizerViewModel: OrganizerViewModel

    var body: some ToolbarContent {
        ToolbarItemGroup {
            Button {
                if let selectedEvent = organizerViewModel.selectedEvent {
                    organizerViewModel.markAsFavorite(event: selectedEvent)
                }
            } label: {
                Image(systemName: organizerViewModel.selectedEvent?.isFavorite == true ? "star.fill" : "star")
            }
            .help("Mark as favorite")
            .disabled(!organizerViewModel.hasSelectedEvent || organizerViewModel.isSelectedClipTypeRecent)

            Button {
                if let selectedEvent = organizerViewModel.selectedEvent {
                    PlatformInterface.revealInFinder(path: selectedEvent.path)
                }
            } label: {
                Image(systemName: "folder")
            }
            .help("Show in Finder")
            .disabled(!organizerViewModel.hasSelectedEvent)

            Button {
                if let selectedEvent = organizerViewModel.selectedEvent {
                    organizerViewModel.removeEvent(event: selectedEvent)
                }
            } label: {
                Image(systemName: "trash")
            }
            .help("Remove event")
            .disabled(!organizerViewModel.hasSelectedEvent)
        }
    }
}


struct DetailToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem {
            Spacer()
        }
    }
}

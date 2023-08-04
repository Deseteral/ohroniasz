import SwiftUI

struct ContentToolbar: ToolbarContent {
    @EnvironmentObject private var eventLibrary: EventLibrary

    var body: some ToolbarContent {
        ToolbarItemGroup {
            Button {
                if let selectedEvent = eventLibrary.selectedEvent {
                    eventLibrary.markAsFavorite(event: selectedEvent)
                }
            } label: {
                Image(systemName: eventLibrary.selectedEvent?.isFavorite == true ? "star.fill" : "star")
            }
            .help("Mark as favorite")
            .disabled(eventLibrary.selectedEvent == nil)

            Button {
                if let selectedEvent = eventLibrary.selectedEvent {
                    PlatformInterface.revealInFinder(path: selectedEvent.path)
                }
            } label: {
                Image(systemName: "folder")
            }
            .help("Show in Finder")
            .disabled(eventLibrary.selectedEvent == nil)

            Button {
                print("remove event")
            } label: {
                Image(systemName: "trash")
            }
            .help("Remove event")
            .disabled(eventLibrary.selectedEvent == nil)
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

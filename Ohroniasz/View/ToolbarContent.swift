import SwiftUI

struct ContentToolbar: ToolbarContent {
    let selectedEvent: CamEvent?

    var body: some ToolbarContent {
        ToolbarItemGroup {
            Button {
                print("mark as favorie")
            } label: {
                Image(systemName: "star")
            }
            .help("Mark as favorite")

            Button {
                if let selectedEvent {
                    PlatformInterface.revealInFinder(path: selectedEvent.path)
                }
            } label: {
                Image(systemName: "folder")
            }
            .help("Show in Finder")

            Button {
                print("remove event")
            } label: {
                Image(systemName: "trash")
            }
            .help("Remove event")
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

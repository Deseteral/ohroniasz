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
            .disabled(selectedEvent == nil)

            Button {
                if let selectedEvent {
                    PlatformInterface.revealInFinder(path: selectedEvent.path)
                }
            } label: {
                Image(systemName: "folder")
            }
            .help("Show in Finder")
            .disabled(selectedEvent == nil)

            Button {
                print("remove event")
            } label: {
                Image(systemName: "trash")
            }
            .help("Remove event")
            .disabled(selectedEvent == nil)
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

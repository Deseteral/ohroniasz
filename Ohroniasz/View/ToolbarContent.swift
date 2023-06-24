import SwiftUI

struct ContentToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItemGroup {
            Button {
                print("show in finder")
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

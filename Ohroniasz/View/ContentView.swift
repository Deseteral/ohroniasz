import SwiftUI

struct ContentView: View {
    @State private var eventFilter: EventFilter = .all

    @EnvironmentObject private var eventLibrary: EventLibrary

    var body: some View {
        NavigationSplitView {
            SidebarView(eventFilter: $eventFilter)
        } content: {
            EventTableView(eventFilter: eventFilter)
        } detail: {
            DetailView()
                .toolbar {
                    DetailToolbar()
                }
        }
        .navigationSubtitle(eventLibrary.libraryPath)
        .onChange(of: self.eventFilter) { _ in
            self.eventLibrary.selectedEvent = nil
        }
    }
}

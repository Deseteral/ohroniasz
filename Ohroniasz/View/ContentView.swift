import SwiftUI

struct ContentView: View {
    @State private var eventFilter: EventFilter = .all
    @State private var selectedEvent: CamEvent? = nil

    @EnvironmentObject private var eventLibrary: EventLibrary

    var body: some View {
        NavigationSplitView {
            SidebarView(eventFilter: $eventFilter)
        } content: {
            EventTableView(eventFilter: eventFilter, selectedEvent: $selectedEvent)
        } detail: {
            DetailView(selectedEvent: selectedEvent)
                .toolbar {
                    DetailToolbar()
                }
        }
        .navigationSubtitle(eventLibrary.libraryPath)
        .onChange(of: self.eventFilter) { _ in
            self.selectedEvent = nil
        }
    }
}

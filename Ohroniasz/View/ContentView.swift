import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var eventLibrary: EventLibrary

    @State private var eventFilter: EventFilter = .all
    @State private var selectedEvent: CamEvent? = nil

    var body: some View {
        NavigationSplitView {
            SidebarView(eventFilter: $eventFilter)
        } content: {
            EventTableView(eventFilter: eventFilter, selectedEvent: $selectedEvent)
        } detail: {
            DetailView(selectedEvent: selectedEvent)
        }
        .onChange(of: self.eventFilter) { _ in
            self.selectedEvent = nil
        }
    }
}

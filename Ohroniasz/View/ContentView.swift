import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var eventLibrary: EventLibrary

    @State private var eventFilter: EventFilter = .all
    @State private var selectedEventId: CamEvent.ID? = nil

    var body: some View {
        NavigationSplitView {
            SidebarView(eventFilter: $eventFilter)
        } content: {
            EventListView(eventFilter: eventFilter, selectedEvent: $selectedEventId)
        } detail: {
            DetailView(selectedEventId: selectedEventId)
        }
        .onChange(of: self.eventFilter) { _ in
            self.selectedEventId = nil
        }
    }
}

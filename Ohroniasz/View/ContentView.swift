import SwiftUI

struct ContentView: View {
    let events: [CamEvent]

    @State private var eventFilter: EventFilter = .all
    @State private var selectedEventId: CamEvent.ID? = nil

    var body: some View {
        NavigationSplitView {
            SidebarView(eventFilter: $eventFilter)
        } content: {
            EventListView(
                events: events,
                eventFilter: eventFilter,
                selectedEvent: $selectedEventId
            )
        } detail: {
            DetailView(events: events, selectedEventId: selectedEventId)
        }
        .onChange(of: self.eventFilter) { _ in
            self.selectedEventId = nil
        }
    }
}

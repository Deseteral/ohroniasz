import SwiftUI

struct EventTableView: View {
    let eventFilter: EventFilter
    @Binding var selectedEvent: CamEvent?

    @State private var selectedEventId: CamEvent.ID? = nil
    @State private var displayEvents: [CamEvent] = []

    @EnvironmentObject private var eventLibrary: EventLibrary

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .medium
        df.dateStyle = .long
        df.locale = Locale.autoupdatingCurrent
        return df
    }()

    private let eventTypeIconColumnWidth: CGFloat = 17

    var body: some View {
        VStack {
            Table(displayEvents, selection: $selectedEventId) {
                TableColumn("") { event in
                    VStack(alignment: .center) {
                        switch event.type {
                            case .savedClip: Image(systemName: "externaldrive.fill").foregroundColor(.blue)
                            case .sentryClip: Image(systemName: "circle.fill").foregroundColor(.red)
                            case .recentClip: Image(systemName: "timer").foregroundColor(.yellow)
                        }
                    }
                    .frame(width: eventTypeIconColumnWidth)
                }
                .width(eventTypeIconColumnWidth)
                
                TableColumn("Date") { event in
                    Text(dateFormatter.string(from: event.date))
                }
                
                TableColumn("Location") { event in
                    if let location = event.location {
                        Text(location.city)
                    } else {
                        EmptyView()
                    }
                }
            }

            if let location = selectedEvent?.location {
                EventLocationView(location: location)
            }
        }
        .frame(minWidth: 420)
        .onAppear {
            self.displayEvents = eventLibrary.filterEvents(type: eventFilter)

            if let selectedEvent {
                self.selectedEventId = selectedEvent.id
            }
        }
        .onChange(of: eventFilter) { nextFilterValue in
            self.displayEvents = eventLibrary.filterEvents(type: nextFilterValue)
        }
        .onChange(of: selectedEventId) { nextSelectedEventId in
            if let nextSelectedEventId {
                self.selectedEvent = eventLibrary.findEvent(by: nextSelectedEventId)
            } else {
                self.selectedEvent = nil
            }
        }
    }
}

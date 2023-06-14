import SwiftUI

struct EventListView: View {
    let eventFilter: EventFilter
    @Binding var selectedEvent: CamEvent.ID?

    @EnvironmentObject private var eventLibrary: EventLibrary

    @State private var displayEvents: [CamEvent] = []

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
            Table(displayEvents, selection: $selectedEvent) {
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

            if let selectedEvent {
                EventLocationView(selectedEventId: selectedEvent)
            }
        }
        .onAppear {
            self.displayEvents = eventLibrary.filterEvents(type: eventFilter)
        }
        .onChange(of: eventFilter) { nextFilterValue in
            self.displayEvents = eventLibrary.filterEvents(type: nextFilterValue)
        }
    }
}

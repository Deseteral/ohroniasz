import SwiftUI

struct EventTableView: View {
    let eventFilter: EventFilter

    @State private var selectedEventId: CamEvent.ID? = nil
    @State private var searchText: String = ""
    @State private var displayEvents: [CamEvent] = []

    @FocusState private var isTableFocused: Bool
    @FocusState private var isDescriptionFieldFocused: Bool

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
                        Image(systemName: event.type.systemImage)
                            .foregroundColor(event.type.color)
                            .help(event.type.helpText)
                    }
                    .frame(width: eventTypeIconColumnWidth)
                }
                .width(eventTypeIconColumnWidth)

                TableColumn("Description") { event in
                    TextField("", text: $eventLibrary.events.first { $0.id == event.id }!.description)
                        .focused($isDescriptionFieldFocused)
                }

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
            .focused($isTableFocused)

            if let location = eventLibrary.selectedEvent?.location {
                EventLocationView(location: location)
            }
        }
        .frame(minWidth: 420)
        .searchable(text: $searchText)
        .toolbar {
            ContentToolbar()
        }
        .onAppear {
            self.displayEvents = eventLibrary.filterEvents(type: eventFilter)

            if let selectedEvent = eventLibrary.selectedEvent {
                self.selectedEventId = selectedEvent.id
            }

            self.isTableFocused = true
        }
        .onChange(of: eventFilter) { nextFilterValue in
            self.displayEvents = eventLibrary.filterEvents(type: nextFilterValue)
        }
        .onChange(of: selectedEventId) { nextSelectedEventId in
            eventLibrary.selectedEventId = nextSelectedEventId
        }
        .onChange(of: isDescriptionFieldFocused) { isDescriptionFieldFocused in
            if !isDescriptionFieldFocused {
                eventLibrary.saveLibraryData()
            }
        }
    }
}

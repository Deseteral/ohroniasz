import SwiftUI

struct EventTableView: View {
    @State private var searchText: String = ""

    @FocusState private var isTableFocused: Bool
    @FocusState private var isDescriptionFieldFocused: Bool

    @EnvironmentObject private var organizerViewModel: OrganizerViewModel

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
            Table(self.organizerViewModel.filteredEvents, selection: $organizerViewModel.selectedEventId) {
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
                    TextField("", text: $organizerViewModel.events.first { $0.id == event.id }!.description)
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

            if let location = organizerViewModel.selectedEvent?.location {
                EventLocationView(location: location)
            }
        }
        .frame(minWidth: 420)
        .searchable(text: $searchText)
        .toolbar {
            ContentToolbar()
        }
        .onAppear {
            self.isTableFocused = true
        }
        .onChange(of: isDescriptionFieldFocused) { isDescriptionFieldFocused in
            if !isDescriptionFieldFocused {
                organizerViewModel.saveLibraryData()
            }
        }
    }
}

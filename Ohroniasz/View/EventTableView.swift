import SwiftUI

struct EventTableView: View {
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
        VStack(spacing: 0) {
            Table(
                organizerViewModel.displayEvents,
                selection: $organizerViewModel.selectedEventId,
                sortOrder: $organizerViewModel.sortOrder
            ) {
                TableColumn("") { event in
                    VStack(alignment: .center) {
                        Image(systemName: event.type.systemImage)
                            .foregroundColor(event.type.color)
                            .help(event.type.helpText)
                    }
                    .frame(width: eventTypeIconColumnWidth)
                }
                .width(eventTypeIconColumnWidth)

                TableColumn("Description", value: \.description) { event in
                    TextField("", text: $organizerViewModel.events.first { $0.id == event.id }!.description)
                        .focused($isDescriptionFieldFocused)
                }
                .width(180)

                TableColumn("Date", value: \.date) { event in
                    Text(dateFormatter.string(from: event.date))
                }
                .width(180)

                TableColumn("Location") { event in
                    if let location = event.location {
                        Text(location.city)
                    } else {
                        EmptyView()
                    }
                }
                .width(180)
            }
            .contextMenu(forSelectionType: CamEvent.ID.self) { items in
                if items.count == 1 {
                    let item = organizerViewModel.getEvent(by: items.first!)!

                    Button("Mark as favorite") {
                        organizerViewModel.markAsFavorite(id: item.id)
                    }
                    Button("Reveal in Finder") {
                        PlatformInterface.revealInFinder(path: item.path)
                    }
                    Button("Move to trash") {
                        organizerViewModel.removeEvent(id: item.id)
                    }
                } else {
                    EmptyView()
                }
            }
            .focused($isTableFocused)

            if let location = organizerViewModel.selectedEvent?.location {
                EventLocationView(location: location)
            }

            WindowStatusBar {
                Text(organizerViewModel.tableStatusBarText)
            }
        }
        .frame(minWidth: 420)
        .searchable(text: $organizerViewModel.searchText)
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

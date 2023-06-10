import SwiftUI

struct EventListView: View {
    let events: [CamEvent]
    @Binding var selectedEvent: CamEvent.ID?
    
    @State private var dateColumnWidth: CGFloat = 200
    private let eventTypeIconColumnWidth: CGFloat = 17
    
    private let dateFormatter = DateFormatter()
    
    init(events: [CamEvent], selectedEvent: Binding<CamEvent.ID?>) {
        self.events = events
        self._selectedEvent = selectedEvent
        
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale.autoupdatingCurrent
    }
    
    var body: some View {
        Table(events, selection: $selectedEvent) {
            TableColumn("") { event in
                VStack(alignment: .center) {
                    switch (event.type) {
                    case .savedClip: Image(systemName: "externaldrive.fill").foregroundColor(.blue)
                    case .sentryClip: Image(systemName: "circle.fill").foregroundColor(.red)
                    }
                }
                .frame(width: eventTypeIconColumnWidth)
            }
            .width(eventTypeIconColumnWidth)
            
            TableColumn("Date") { event in
                Text(dateFormatter.string(from: event.date))
                    .overlay( GeometryReader { geo in Color.clear.onAppear { self.dateColumnWidth = geo.size.width }})
            }
//            .width(self.dateColumnWidth)

            TableColumn("Location", value: \.location.city)
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView(events: [], selectedEvent: .constant(nil))
    }
}

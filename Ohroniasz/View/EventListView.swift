import SwiftUI

struct EventListView: View {
    let events: [CamEvent]
    
    @State private var dateColumnWidth: CGFloat = 160
    private let kindIconColumnWidth: CGFloat = 17
    
    private let dateFormatter = DateFormatter()
    
    init(events: [CamEvent]) {
        self.events = events
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale.autoupdatingCurrent
    }
    
    var body: some View {
        Table(events) {
            TableColumn("") { event in
                VStack(alignment: .center) {
                    switch (event.kind) {
                    case .savedClip: Image(systemName: "externaldrive.fill").foregroundColor(.blue)
                    case .sentryClip: Image(systemName: "circle.fill").foregroundColor(.red)
                    }
                }
                .frame(width: kindIconColumnWidth)
            }
            .width(kindIconColumnWidth)
            
            TableColumn("Date") { event in
                Text(dateFormatter.string(from: event.date))
                    .overlay( GeometryReader { geo in Color.clear.onAppear { self.dateColumnWidth = geo.size.width }})
            }
            .width(self.dateColumnWidth)

            TableColumn("Path", value: \.path)
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView(events: [])
    }
}

import SwiftUI

struct EventListView: View {
    let events: [CamEvent]
    
    let dtFormatter = DateFormatter()
    
    init(events: [CamEvent]) {
        self.events = events
        dtFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    var body: some View {
        Table(events) {
            TableColumn("") { event in
                switch (event.kind) {
                case .savedClip: Image(systemName: "externaldrive.fill").foregroundColor(.blue)
                case .sentryClip: Image(systemName: "circle.fill").foregroundColor(.red)
                }
                
            }
            .width(15)
            
            TableColumn("Date") { event in
                Text(dtFormatter.string(from: event.date))
            }
            .width(160)

            TableColumn("Path", value: \.path)
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView(events: [])
    }
}

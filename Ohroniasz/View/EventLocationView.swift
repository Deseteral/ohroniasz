import SwiftUI
import MapKit

struct EventLocationView: View {
    let selectedEventId: CamEvent.ID

    // This is a workaround for "Modifying state during view update, this will cause undefined behavior" issue.
    @State private var region: MKCoordinateRegion = .init()
    private var regionBinding: Binding<MKCoordinateRegion> {
        .init(
            get: { region },
            set: { newValue in DispatchQueue.main.async { region = newValue } }
        )
    }

    @State private var markers: [Marker] = []

    @EnvironmentObject private var eventLibrary: EventLibrary

    var body: some View {
        Map(coordinateRegion: regionBinding, annotationItems: markers) {
            marker in MapMarker(coordinate: marker.coordinate)
        }
        .frame(maxHeight: 280)
        .onAppear {
            setRegion(for: selectedEventId)
        }
        .onChange(of: selectedEventId) { nextSelectedEventId in
            setRegion(for: nextSelectedEventId)
        }
    }

    private func setRegion(for eventId: CamEvent.ID) {
        guard let location = eventLibrary.findEvent(by: eventId)?.location else { return }

        let center = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)

        self.region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005))
        self.markers = [Marker(id: eventId, coordinate: center)]
    }
}

fileprivate struct Marker: Identifiable {
    let id: CamEvent.ID
    var coordinate: CLLocationCoordinate2D
}

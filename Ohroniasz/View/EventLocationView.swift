import SwiftUI
import MapKit

struct EventLocationView: View {
    let location: CamEventLocation

    // This is a workaround for "Modifying state during view update, this will cause undefined behavior" issue.
    @State private var region: MKCoordinateRegion = .init()
    private var regionBinding: Binding<MKCoordinateRegion> {
        .init(
            get: { region },
            set: { newValue in DispatchQueue.main.async { region = newValue } }
        )
    }

    @State private var markers: [Marker] = []
    @State private var buttonOpacity = 0.0

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(coordinateRegion: regionBinding, annotationItems: markers) {
                marker in MapMarker(coordinate: marker.coordinate)
            }

            Button(action: { print("Open in maps") }, label: {
                HStack {
                    Text("Open in Apple Maps")
                    Image(systemName: "map")
                }
            })
            .opacity(buttonOpacity)
            .shadow(radius: 4)
            .buttonStyle(.link)
            .padding()
        }
        .frame(maxHeight: 280)
        .onAppear {
            setRegion(for: location)
        }
        .onChange(of: location) { nextLocation in
            setRegion(for: nextLocation)
        }
        .onHover { isHovering in
            withAnimation {
                self.buttonOpacity = isHovering ? 1 : 0
            }
        }
    }

    private func setRegion(for location: CamEventLocation) {
        let center = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)

        self.region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005))
        self.markers = [Marker(coordinate: center)]
    }
}

fileprivate struct Marker: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

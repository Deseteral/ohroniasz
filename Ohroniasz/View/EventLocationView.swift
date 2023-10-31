import SwiftUI
import MapKit

struct EventLocationView: View {
    let location: CamEventLocation

    @State private var markers: [EventLocationMarker] = []
    @State private var buttonOpacity = 0.0

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(bounds: MapCameraBounds(minimumDistance: 150)) {
                ForEach(markers) { marker in
                    Marker("Event location", coordinate: marker.coordinate)
                }
            }

            Button(action: { openLocationInMaps() }, label: {
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
            setMarkers(for: location)
        }
        .onChange(of: location) { _, nextLocation in
            setMarkers(for: nextLocation)
        }
        .onHover { isHovering in
            withAnimation {
                self.buttonOpacity = isHovering ? 1 : 0
            }
        }
    }

    private func setMarkers(for location: CamEventLocation) {
        let center = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
        self.markers = [EventLocationMarker(coordinate: center)]
    }

    private func openLocationInMaps() {
        let query = "Sentry event location".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        PlatformInterface.openInDefaultBrowser(url: URL(string: "http://maps.apple.com/?ll=\(location.lat),\(location.lon)&q=\(query)")!)
    }
}

fileprivate struct EventLocationMarker: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

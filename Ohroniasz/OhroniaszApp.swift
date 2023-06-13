import SwiftUI

@main
struct OhroniaszApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var events: [CamEvent] = []

    var body: some Scene {
        WindowGroup {
            Group {
                if events.count > 0 {
                    ContentView(events: events)
                } else {
                    WelcomeView() { libraryPath in
                        self.events = LibraryScanner.scanLibrary(atPath: libraryPath)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

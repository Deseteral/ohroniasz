import SwiftUI
import AppKit

@main
struct OhroniaszApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) fileprivate var appDelegate

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

fileprivate class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

import SwiftUI
import AppKit

@main
struct OhroniaszApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) fileprivate var appDelegate

    @StateObject private var eventLibrary = EventLibrary()

    var body: some Scene {
        WindowGroup {
            Group {
                if eventLibrary.hasEventsLoaded {
                    ContentView()
                } else {
                    WelcomeView() { libraryPath in
                        let events = LibraryScanner.scanLibrary(atPath: libraryPath)
                        self.eventLibrary.libraryPath = libraryPath
                        self.eventLibrary.events = events
                    }
                }
            }
            .environmentObject(eventLibrary)
            .preferredColorScheme(.dark)
        }
    }
}

fileprivate class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

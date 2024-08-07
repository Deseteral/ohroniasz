import SwiftUI
import AppKit
import os

@main
struct OhroniaszApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) fileprivate var appDelegate

    @StateObject private var organizerViewModel = OrganizerViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if organizerViewModel.hasEventsLoaded {
                    ContentView()
                } else {
                    WelcomeView() { libraryPath in
                        self.organizerViewModel.loadEvents(from: libraryPath)
                    }
                }
            }
            .environmentObject(organizerViewModel)
            .preferredColorScheme(.dark)
        }
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
    }
}

fileprivate class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

func makeLogger(for category: String) -> Logger {
    return Logger(subsystem: "xyz.deseteral.ohroniasz", category: category)
}

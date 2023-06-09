import SwiftUI

@main
struct OhroniaszApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var libraryManager: LibraryManager? = nil
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let libraryManager = libraryManager {
                    Text("hello")
                } else {
                    WelcomeView() { libraryPath in
                        self.libraryManager = LibraryManager(libraryPath: libraryPath)
                        self.libraryManager?.scanLibrary()
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

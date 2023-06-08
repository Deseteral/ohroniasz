import SwiftUI

@main
struct OhroniaszApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .preferredColorScheme(.dark)
        }
    }
}

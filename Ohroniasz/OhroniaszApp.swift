import SwiftUI

enum EventFilter: String, CaseIterable {
    case all = "All clips"
    case sentry = "Sentry"
    case saved = "Saved clips"
    case sentryAndSaved = "Sentry & saved"
}

@main
struct OhroniaszApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var eventFilter: EventFilter = .all
    @State private var events: [CamEvent] = []
    @State private var selectedEvent: CamEvent.ID? = nil
    
    @State private var libraryManager: LibraryManager? = nil
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLibraryLoaded {
                    NavigationSplitView {
                        List(selection: $eventFilter) {
                            ForEach(EventFilter.allCases, id: \.rawValue) { filter in
                                NavigationLink(filter.rawValue, value: filter)
                            }
                        }
                    } content: {
                        EventListView(events: events, selectedEvent: $selectedEvent)
                    } detail: {
                        if selectedEvent == nil {
                            Text("Select video clip from the list.")
                        } else {
                            VideoGridView()
                        }
                    }
                    .onChange(of: self.eventFilter) { _ in
                        self.selectedEvent = nil
                    }
                } else {
                    WelcomeView() { libraryPath in
                        self.libraryManager = LibraryManager(libraryPath: libraryPath)
                        self.events = self.libraryManager!.scanLibrary()
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private var isLibraryLoaded: Bool {
        return self.libraryManager != nil
    }
}

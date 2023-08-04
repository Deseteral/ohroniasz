import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var organizerViewModel: OrganizerViewModel

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } content: {
            EventTableView()
        } detail: {
            DetailView()
                .toolbar { DetailToolbar() }
        }
        .navigationSubtitle(organizerViewModel.libraryPath)
    }
}

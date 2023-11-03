import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var organizerViewModel: OrganizerViewModel

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(NavigationSplitViewVisibility.doubleColumn)) {
            EmptyView()
                .toolbar(.hidden, for: .windowToolbar)
                .toolbar(removing: .sidebarToggle)
        } content: {
            EventTableView()
                .toolbar { ContentToolbar() }
        } detail: {
            DetailView()
                .toolbar { DetailToolbar() }
        }
        .navigationSubtitle(organizerViewModel.libraryPath)
    }
}

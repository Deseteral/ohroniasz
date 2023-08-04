import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var organizerViewModel: OrganizerViewModel

    var body: some View {
        List(selection: $organizerViewModel.eventFilter) {
            ForEach(EventFilter.allCases, id: \.rawValue) { filter in
                NavigationLink(value: filter) {
                    Label(filter.rawValue, systemImage: filter.systemIcon)
                }
            }
        }
        .frame(minWidth: 180)
    }
}

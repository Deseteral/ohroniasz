import SwiftUI

struct SidebarView: View {
    @Binding var eventFilter: EventFilter

    var body: some View {
        List(selection: $eventFilter) {
            ForEach(EventFilter.allCases, id: \.rawValue) { filter in
                NavigationLink(value: filter) {
                    Label(filter.rawValue, systemImage: filter.systemIcon)
                }
            }
        }
        .frame(minWidth: 180)
    }
}

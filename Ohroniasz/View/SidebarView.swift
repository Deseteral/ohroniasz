import SwiftUI

struct SidebarView: View {
    @Binding var eventFilter: EventFilter

    var body: some View {
        List(selection: $eventFilter) {
            ForEach(EventFilter.allCases, id: \.rawValue) { filter in
                NavigationLink(value: filter) {
                    HStack {
                        Image(systemName: filter.systemIcon)
                            .foregroundColor(.accentColor)
                            .frame(width: 18)
                        Text(filter.rawValue)
                    }
                }
            }
        }
    }
}

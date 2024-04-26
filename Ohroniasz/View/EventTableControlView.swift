import Foundation
import SwiftUI

struct EventTableControlView: View {
    @EnvironmentObject private var organizerViewModel: OrganizerViewModel

    var body: some View {
        VStack {
            Picker(selection: $organizerViewModel.eventFilter, label: Text("Type")) {
                ForEach(EventFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .labelsHidden()
            .padding(8)
        }
    }
}

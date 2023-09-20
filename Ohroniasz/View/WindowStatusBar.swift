import SwiftUI

struct WindowStatusBar<Content: View>: View {
    public var contentView: () -> Content

    var body: some View {
        VStack {
            Divider()
            HStack(alignment: .center) {
                contentView()
            }
            .padding(.bottom, 6)
        }
    }
}

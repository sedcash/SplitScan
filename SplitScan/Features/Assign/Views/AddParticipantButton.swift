import SwiftUI

struct AddParticipantButton: View {
    enum Metrics {
        static let height: CGFloat = 36
        static let iconSize: CGFloat = 18
    }

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: Metrics.iconSize, height: Metrics.iconSize)

                Text("Add Person")
            }
            .padding(.horizontal, Spacing.lg)
            .frame(height: Metrics.height)
            .background(Color.blue.opacity(0.20))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

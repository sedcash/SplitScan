import SwiftUI

struct ParticipantAssignmentButton: View {
    enum Metrics {
        static let cornerRadius: CGFloat = 12
        static let height: CGFloat = 50
        static let horizontalPadding: CGFloat = 16
        static let width: CGFloat = 120
    }

    let isSelected: Bool
    let participant: Participant

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ParticipantLabelView(participant: participant)
                .frame(width: Metrics.width, height: Metrics.height, alignment: .leading)
                .padding(.horizontal, Metrics.horizontalPadding)
                .background(backgroundView)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: Metrics.cornerRadius)
            .fill(isSelected ? Color.blue.opacity(0.10) : Color.white)
            .stroke(
                isSelected ? Color.blue : Color.gray.opacity(0.25),
                lineWidth: isSelected ? 2 : 1
            )
    }
}

import SwiftUI

struct ParticipantLabelView: View {
    enum Metrics {
        static let dotSize: CGFloat = 16
        static let minHeight: CGFloat = 32
    }

    let participant: Participant

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Circle()
                .fill(Color(hex: participant.colorHex))
                .frame(width: Metrics.dotSize, height: Metrics.dotSize)

            Text(participant.name)
                .frame(minHeight: Metrics.minHeight)
        }
    }
}

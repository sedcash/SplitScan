import SwiftUI

struct AssignItemRowView: View {
    enum Metrics {
        static let cornerRadius: CGFloat = 16
        static let shadowOpacity: Double = 0.08
        static let shadowRadius: CGFloat = 6
        static let shadowYOffset: CGFloat = 3
    }

    let item: ReceiptLineItem
    let participants: [Participant]
    let assignedParticipants: [Participant]
    let onParticipantTapped: (Participant) -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            topSection

            if isExpanded {
                expandedSection
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                .stroke(Color.black.opacity(0.05))
        )
        .shadow(
            color: .black.opacity(Metrics.shadowOpacity),
            radius: Metrics.shadowRadius,
            y: Metrics.shadowYOffset
        )
    }

    private var topSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ItemView(
                title: item.name,
                amount: item.totalPrice.formatted(),
                quantity: item.quantity
            )

            if !assignedParticipants.isEmpty {
                FlowLayout {
                    ForEach(assignedParticipants, id: \.id) { participant in
                        AssignedParticipantBadge(participant: participant)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            isExpanded.toggle()
        }
    }

    private var expandedSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Assign to:")
                    .font(.headline)

                FlowLayout {
                    ForEach(participants, id: \.id) { participant in
                        ParticipantAssignmentButton(
                            isSelected: assignedParticipants.contains { $0.id == participant.id },
                            participant: participant
                        ) {
                            onParticipantTapped(participant)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background(Color(.systemGray6))
    }
}

private struct AssignedParticipantBadge: View {
    let participant: Participant

    var body: some View {
        Text(participant.name)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .frame(height: 28)
            .background(Color(hex: participant.colorHex))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    AssignItemRowView(
        item: PreviewData.pizzaItem,
        participants: [PreviewData.mike, PreviewData.sarah],
        assignedParticipants: [PreviewData.mike],
        onParticipantTapped: { _ in }
    )
}

import SwiftUI

struct AssignItemsView: View {
    enum Metrics {
        static let contentPadding: CGFloat = 20
        static let headerBottomPadding: CGFloat = 16
        static let participantSectionCornerRadius: CGFloat = 16
        static let sectionSpacing: CGFloat = 20
    }

    @State var viewModel: AssignItemsViewModel

    init(viewModel: AssignItemsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScreenShellView {
            header
        } content: {
            content
        } footer: {
            footer
        }
        .sheet(item: sheetBinding) { mode in
            EditFormSheetView(
                mode: mode,
                availableColors: viewModel.availableParticipantColors(),
                isSaveEnabled: viewModel.canSaveParticipant,
                validationErrors: viewModel.addParticipantErrors,
                state: $viewModel.addParticipantState,
                onCancel: {
                    viewModel.dismissSheet()
                },
                onSave: {
                    viewModel.saveAddParticipant()
                }
            )
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "person.2.fill")
                    .resizable()
                    .frame(width: 20, height: 20)

                Text("Assign Items")
                    .font(.headline)
            }

            Text("Tap items to assign to people")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Metrics.contentPadding)
        .padding(.bottom, Metrics.headerBottomPadding)
    }

    private var content: some View {
        VStack(spacing: Metrics.sectionSpacing) {
            participantsSection

            LazyVStack(spacing: Spacing.md) {
                ForEach(viewModel.receipt.items) { item in
                    AssignItemRowView(
                        item: item,
                        participants: viewModel.participants,
                        assignedParticipants: viewModel.assignedParticipants(for: item.id),
                        onParticipantTapped: { participant in
                            viewModel.toggleAssignment(
                                itemID: item.id,
                                participantID: participant.id
                            )
                        }
                    )
                }
            }
        }
        .padding(Metrics.contentPadding)
    }

    private var participantsSection: some View {
        FlowLayout {
            ForEach(viewModel.receipt.participants, id: \.id) { participant in
                ParticipantChipView(
                    participant: participant,
                    action: {
                        viewModel.removeParticipant(id: participant.id)
                    }
                )
            }

            AddParticipantButton(action: viewModel.showAddParticipantSheet)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Metrics.participantSectionCornerRadius)
                .fill(Color(.systemBackground))
        )
    }

    private var footer: some View {
        FooterButtonView(
            title: "View Summary",
            trailingSystemImage: "chevron.right",
            isEnabled: viewModel.allItemsAssigned,
            error: "Please assign all items before continuing",
            action: viewModel.viewSummary
        )
    }

    private var sheetBinding: Binding<EditSheetMode?> {
        Binding(
            get: { viewModel.editSheetMode },
            set: { viewModel.editSheetMode = $0 }
        )
    }
}

private struct ParticipantChipView: View {
    let participant: Participant
    let action: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            ParticipantLabelView(participant: participant)

            Button(action: action) {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(.black)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.1))
        )
    }
}

#Preview("Assign Items") {
    NavigationStack {
        AssignItemsView(
            viewModel: PreviewFactory.makeAssignItemsViewModel()
        )
    }
}

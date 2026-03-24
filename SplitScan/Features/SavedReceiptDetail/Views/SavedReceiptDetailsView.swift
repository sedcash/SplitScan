import SwiftUI

struct SavedReceiptDetailsView: View {
    enum Metrics {
        static let imageCornerRadius: CGFloat = 16
        static let imageSize: CGFloat = 220
        static let contentPadding: CGFloat = 20
        static let participantChipHorizontalPadding: CGFloat = 12
        static let participantChipVerticalPadding: CGFloat = 8
        static let sectionSpacing: CGFloat = 20
    }

    @State var viewModel: SavedReceiptDetailViewModel

    var body: some View {
        ScreenShellView {
            header
        } content: {
            content
        } footer: {
            footer
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.load()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                PrimaryButton(
                    title: "Delete",
                    style: .secondary,
                    width: .fit,
                    action: viewModel.deleteReceiptTapped
                )
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(viewModel.savedReceipt?.merchantName ?? "Untitled")
                .font(.largeTitle.weight(.semibold))

            Text(viewModel.savedReceipt?.date.displayDate ?? "Unknown Date")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let savedReceipt = viewModel.savedReceipt {
                PaymentStatusView(
                    text: savedReceipt.paidStatusText,
                    textColor: savedReceipt.paymentStatus.color
                )
            }
        }
        .padding(Metrics.contentPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footer: some View {
        FooterButtonView(
            title: "View Payment Summary",
            leadingSystemImage: "chevron.right",
            isEnabled: viewModel.savedReceipt != nil,
            action: viewModel.viewPaymentSummaryTapped
        )
    }

    private var content: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else if viewModel.savedReceipt == nil {
                Text("Receipt not found")
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                loadedContent
            }
        }
    }

    private var loadedContent: some View {
        VStack(spacing: Metrics.sectionSpacing) {
            imageSection
            participantsSection
            itemsSection

            if let totals = viewModel.savedReceipt?.totals {
                TotalsView(totals: totals)
                    .cardStyle()
            }
        }
        .padding(Metrics.contentPadding)
    }

    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "person.2.fill")
                    .resizable()
                    .frame(width: 20, height: 20)

                Text("Participants")
                    .font(.headline)
            }

            FlowLayout {
                ForEach(viewModel.participants, id: \.id) { participant in
                    participantChip(for: participant)
                }
            }
        }
        .padding()
        .cardStyle()
    }

    private var imageSection: some View {
        VStack(spacing: Spacing.md) {
            imageContent
                .frame(width: Metrics.imageSize, height: Metrics.imageSize)
                .background(
                    RoundedRectangle(cornerRadius: Metrics.imageCornerRadius)
                        .fill(Color(.secondarySystemBackground))
                )
                .clipShape(RoundedRectangle(cornerRadius: Metrics.imageCornerRadius))
        }
        .frame(maxWidth: .infinity)
    }

    private var imageContent: some View {
        Group {
            if
                let imagePath = viewModel.savedReceipt?.imagePath,
                let uiImage = UIImage(contentsOfFile: imagePath)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
                    .padding(40)
            }
        }
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Items")
                .font(.title3.weight(.semibold))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            ForEach(Array((viewModel.savedReceipt?.items ?? []).enumerated()), id: \.element.id) { index, item in
                VStack(spacing: 0) {
                    ItemView(
                        title: item.name,
                        amount: item.price.formatted(),
                        quantity: item.quantity
                    )
                    .padding()

                    if index < (viewModel.savedReceipt?.items.count ?? 0) - 1 {
                        Divider()
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .cardStyle()
    }

    private func avatar(for participant: Participant) -> some View {
        Text(initial(for: participant))
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(Color(hex: participant.colorHex))
            )
    }

    private func initial(for participant: Participant) -> String {
        let trimmed = participant.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.first.map { String($0).uppercased() } ?? "?"
    }

    private func participantChip(for participant: Participant) -> some View {
        HStack(spacing: 8) {
            avatar(for: participant)

            Text(participant.name)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, Metrics.participantChipHorizontalPadding)
        .padding(.vertical, Metrics.participantChipVerticalPadding)
        .background(
            Capsule()
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    SavedReceiptDetailsView(
        viewModel: PreviewFactory.makeSavedReceiptDetailViewModel()
    )
}

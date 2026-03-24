import Foundation
import SwiftUI

enum TipSplitMethodSelection: String, Hashable, CaseIterable, Sendable {
    case proportional
    case equal
    case onePerson

    var title: String {
        switch self {
        case .proportional:
            "Proportional"
        case .equal:
            "Equal"
        case .onePerson:
            "One Person"
        }
    }
}

struct SummaryView: View {
    enum Metrics {
        static let overlayBackgroundOpacity: Double = 0.35
        static let overlayCornerRadius: CGFloat = 28
        static let overlayHorizontalPadding: CGFloat = 24
        static let overlayMaxWidth: CGFloat = 540
        static let overlayPadding: CGFloat = 24
        static let sectionSpacing: CGFloat = 24
        static let headerHorizontalPadding: CGFloat = 20
        static let headerBottomPadding: CGFloat = 20
        static let totalsCornerRadius: CGFloat = 16
    }

    @State var viewModel: SummaryViewModel
    @State private var isShowingShareSheet = false
    @State private var shareItems: [Any] = []

    init(viewModel: SummaryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            ScreenShellView {
                header
            } content: {
                content
            } footer: {
                footer
            }

            if let overlay = viewModel.overlay {
                overlayBackdrop

                switch overlay {
                case .addPayment:
                    addPaymentOverlay

                case .paymentHistory(let participantID):
                    PaymentHistoryView(
                        records: viewModel.getPayments(for: participantID),
                        totalPaid: viewModel.getPaymentsTotal(
                            payments: viewModel.getPayments(for: participantID)
                        ),
                        dismissAction: viewModel.dismissOverlay,
                        deleteRecord: { paymentID in
                            viewModel.deletePayment(paymentID, participantID: participantID)
                        }
                    )

                case .tipEditor:
                    tipEditorOverlay
                }
            }
        }
        .sheet(isPresented: $isShowingShareSheet) {
            ActivityViewController(activityItems: shareItems)
        }
        .toolbar {
            summaryToolbar
        }
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Payment Summary")
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(.white)

            Text("Here’s how much everyone owes")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.95))
        }
        .padding(.horizontal, Metrics.headerHorizontalPadding)
        .padding(.bottom, Metrics.headerBottomPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Rectangle()
                .fill(Color.blue)
                .ignoresSafeArea(edges: .top)
        )
    }

    @ToolbarContentBuilder
    private var summaryToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            switch viewModel.mode {
            case .edit:
                Button("Save") {
                    Task { await viewModel.saveTapped() }
                }

                Button("Cancel") {
                    viewModel.doneTapped()
                }

            case .saved:
                Menu {
                    Button("Edit Items") {
                        viewModel.editItemsButtonTapped()
                    }

                    Button("Edit Assignments") {
                        viewModel.editAssignmentsButtonTapped()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }

            case .share:
                EmptyView()
            }
        }
    }

    private var content: some View {
        VStack(spacing: Spacing.xl) {
            ForEach(viewModel.breakdowns, id: \.id) { breakdown in
                ParticipantBreakdownView(
                    showPaymentsSection: viewModel.mode != .share,
                    breakdown: breakdown,
                    addPayment: {
                        viewModel.showAddPayment(for: breakdown.participant.id)
                    },
                    payBalance: {
                        viewModel.payBalance(for: breakdown.id)
                    },
                    resetBalance: {
                        viewModel.resetBalance(for: breakdown.id)
                    },
                    viewHistory: {
                        viewModel.viewHistory(for: breakdown.id)
                    }
                )
            }

            totals
        }
        .padding()
    }

    private var footer: some View {
        FooterButtonView(
            title: "Share Summary",
            leadingSystemImage: "square.and.arrow.up",
            isEnabled: true,
            action: shareSummary
        )
    }

    private var overlayBackdrop: some View {
        Color.black.opacity(Metrics.overlayBackgroundOpacity)
            .ignoresSafeArea()
            .onTapGesture {
                viewModel.dismissOverlay()
            }
    }

    private var quickTipButtons: some View {
        HStack(spacing: 12) {
            ForEach(viewModel.quickTipPercents, id: \.self) { percent in
                PrimaryButton(
                    title: "\(percent)%",
                    style: viewModel.selectedTipPercent == percent ? .primary : .secondary,
                    width: .fill
                ) {
                    viewModel.selectQuickTipPercent(percent)
                }
            }
        }
    }

    private var addPaymentOverlay: some View {
        VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
            makeNumberTextField(
                title: "Payment Amount",
                text: $viewModel.addPaymentAmountText
            )

            HStack(spacing: 16) {
                PrimaryButton(
                    title: "Cancel",
                    style: .secondary,
                    width: .fill,
                    action: viewModel.dismissOverlay
                )

                PrimaryButton(
                    title: "Add Payment",
                    style: .primary,
                    width: .fill,
                    isEnabled: Decimal(string: viewModel.addPaymentAmountText).map { $0 > 0 } ?? false,
                    action: viewModel.addPayment
                )
            }
        }
        .padding(Metrics.overlayPadding)
        .frame(maxWidth: Metrics.overlayMaxWidth)
        .background(
            RoundedRectangle(cornerRadius: Metrics.overlayCornerRadius)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        )
        .padding(.horizontal, Metrics.overlayHorizontalPadding)
    }

    private var selectPersonForTipMenu: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Who pays the tip?")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)

            Menu {
                ForEach(viewModel.receipt.participants, id: \.id) { participant in
                    Button(participant.name) {
                        viewModel.setOnePersonTipParticipant(participant.id)
                    }
                }
            } label: {
                HStack {
                    Text(
                        viewModel.receipt.participants.first(where: {
                            $0.id == viewModel.selectedOnePersonTipParticipantID
                        })?.name ?? "Select person"
                    )

                    Spacer()

                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var tipEditorOverlay: some View {
        VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
            HStack {
                Text("Add Tip")
                    .font(.largeTitle.weight(.semibold))

                Spacer()

                Toggle(
                    "",
                    isOn: Binding(
                        get: { viewModel.hasTip },
                        set: { isOn in
                            if isOn == false {
                                viewModel.clearTip()
                            } else if viewModel.receipt.totals.tip == nil {
                                viewModel.selectQuickTipPercent(15)
                            }
                        }
                    )
                )
                .labelsHidden()
            }

            if viewModel.hasTip {
                VStack(alignment: .leading, spacing: 12) {
                    quickTipButtons

                    makeNumberTextField(
                        title: "Custom Amount",
                        text: Binding(
                            get: { viewModel.tipAmountText },
                            set: { viewModel.updateCustomTipAmount($0) }
                        )
                    )

                    Text("Split Method")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        ForEach(TipSplitMethodSelection.allCases, id: \.self) { method in
                            PrimaryButton(
                                title: method.title,
                                style: viewModel.tipSplitMethodSelection == method ? .primary : .secondary,
                                width: .fit
                            ) {
                                viewModel.setTipSplitMethod(method)
                            }
                        }
                    }

                    if viewModel.tipSplitMethodSelection == .onePerson {
                        selectPersonForTipMenu
                    }
                }
            }
        }
        .padding(Metrics.overlayPadding)
        .frame(maxWidth: Metrics.overlayMaxWidth)
        .background(
            RoundedRectangle(cornerRadius: Metrics.overlayCornerRadius)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        .padding(.horizontal, Metrics.overlayHorizontalPadding)
    }

    private func makeNumberTextField(
        title: String,
        text: Binding<String>
    ) -> some View {
        FormFieldSection(title: title) {
            TextFieldWithImage(
                imageName: "dollarsign",
                placeholder: "0.00",
                text: text
            )
        }
    }

    private func shareSummary() {
        Task {
            let items = await viewModel.buildShareItems()
            guard !items.isEmpty else { return }

            shareItems = items

            await MainActor.run {
                isShowingShareSheet = true
            }
        }
    }

    private var totals: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Text("Total Bill")
                    .font(.title2)
                    .foregroundStyle(.white)

                Spacer()

                Text("Split Between")
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            HStack {
                Text(viewModel.receipt.totals.grandTotal.formatted())
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(.white)

                Spacer()

                let personCountText = viewModel.receipt.participants.count == 1 ? "Person" : "People"
                Text("\(viewModel.receipt.participants.count) \(personCountText)")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.white.opacity(0.5))

            HStack {
                Text("Payment Status")
                    .font(.title2)
                    .foregroundStyle(.white)

                Spacer()

                PaymentStatusView(
                    text: viewModel.receipt.paidStatusText,
                    textColor: viewModel.receipt.isPaid ? .green : .orange
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Metrics.totalsCornerRadius)
                .fill(Color.blue)
        )
    }
}

#Preview("Summary View") {
    NavigationStack {
        SummaryView(
            viewModel: PreviewFactory.makeSummaryViewModel()
        )
    }
}

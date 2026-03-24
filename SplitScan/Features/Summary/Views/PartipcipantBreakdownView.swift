import SwiftUI

struct ParticipantBreakdownView: View {
    enum Metrics {
        static let avatarSize: CGFloat = 56
        static let cardCornerRadius: CGFloat = 20
        static let cardShadowOpacity: Double = 0.08
        static let cardShadowRadius: CGFloat = 6
        static let cardShadowYOffset: CGFloat = 3
        static let headerAccentHeight: CGFloat = 14
        static let participantNameFontSize: CGFloat = 24
        static let totalFontSize: CGFloat = 30
    }

    let showPaymentsSection: Bool
    let breakdown: ParticipantBreakdown

    let addPayment: () -> Void
    let payBalance: () -> Void
    let resetBalance: () -> Void
    let viewHistory: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            header

            if showPaymentsSection {
                paymentSection
                actionButtonsContainer
            }

            Divider()
            totalsSection
            Divider()
            itemsSection
        }
        .padding()
        .background(cardBackground)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            avatar

            VStack(alignment: .leading, spacing: 4) {
                Text(breakdown.participant.name)
                    .font(.system(size: Metrics.participantNameFontSize, weight: .semibold))

                Text("\(breakdown.itemCount) items")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                PaymentStatusView(
                    text: breakdown.paymentStatus.rawValue.capitalized,
                    textColor: breakdown.paymentStatus.color
                )

                Text(breakdown.total.formatted())
                    .font(.system(size: Metrics.totalFontSize, weight: .medium))
                    .foregroundStyle(.blue)
            }
        }
    }

    private var avatar: some View {
        Text(String(breakdown.participant.name.prefix(1)).uppercased())
            .font(.system(size: 28, weight: .medium, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: Metrics.avatarSize, height: Metrics.avatarSize)
            .background(Color(hex: breakdown.participant.colorHex))
            .clipShape(Circle())
    }

    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(breakdown.lastDateString)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressBar(
                progress: breakdown.paidProgress,
                color: breakdown.paymentStatus.color
            )

            HStack {
                Spacer()

                Text("\(breakdown.paidProgressString) Paid")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            if breakdown.paymentStatus == .partial, let lastPayment = breakdown.lastPayment {
                MoneyLabel(
                    title: "Paid",
                    value: lastPayment.amount.formatted(),
                    valueColor: .green
                )

                MoneyLabel(
                    title: "Remaining",
                    value: breakdown.remainingBalance.formatted(),
                    valueColor: .red
                )
            }
        }
    }

    private var actionButtonsContainer: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Spacing.md) {
                actionButtons
            }

            VStack(spacing: Spacing.md) {
                actionButtons
            }
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        let hasPaymentHistory = breakdown.lastPayment != nil

        if breakdown.paymentStatus != .paid {
            PrimaryButton(
                title: breakdown.paymentStatus == .partial ? "Pay Remaining" : "Mark Paid",
                width: .fill,
                action: payBalance
            )

            PrimaryButton(
                title: "Add Payment",
                leadingSystemImage: "plus",
                style: .secondary,
                width: .fill,
                action: addPayment
            )
        }

        if hasPaymentHistory {
            PrimaryButton(
                title: "Payments",
                leadingSystemImage: "clock.arrow.circlepath",
                style: .secondary,
                width: .fill,
                action: viewHistory
            )
        }

        if hasPaymentHistory || breakdown.paymentStatus == .paid {
            PrimaryButton(
                title: "Clear",
                leadingSystemImage: "xmark",
                style: .secondary,
                width: .fill,
                action: resetBalance
            )
        }
    }

    private var totalsSection: some View {
        TotalsView(
            totals: breakdown.totals,
            showsTotal: false
        )
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Items")
                .font(.title3.weight(.semibold))

            VStack(spacing: Spacing.sm) {
                ForEach(breakdown.lines, id: \.id) { line in
                    MoneyLabel(
                        title: itemTitle(for: line),
                        value: line.amount.formatted()
                    )
                }
            }
        }
    }

    private var cardBackground: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: Metrics.cardCornerRadius)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(Metrics.cardShadowOpacity),
                    radius: Metrics.cardShadowRadius,
                    y: Metrics.cardShadowYOffset
                )

            UnevenRoundedRectangle(
                topLeadingRadius: Metrics.cardCornerRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: Metrics.cardCornerRadius
            )
            .fill(Color(hex: breakdown.participant.colorHex))
            .frame(height: Metrics.headerAccentHeight)
        }
    }

    private func itemTitle(for line: ParticipantLineCharge) -> String {
        guard let suffix = line.displaySuffix, !suffix.isEmpty else {
            return line.itemName
        }

        return "\(line.itemName) \(suffix)"
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            ParticipantBreakdownView(
                showPaymentsSection: true,
                breakdown: PreviewData.partial,
                addPayment: {},
                payBalance: {},
                resetBalance: {},
                viewHistory: {}
            )

            ParticipantBreakdownView(
                showPaymentsSection: true,
                breakdown: PreviewData.unpaid,
                addPayment: {},
                payBalance: {},
                resetBalance: {},
                viewHistory: {}
            )

            ParticipantBreakdownView(
                showPaymentsSection: false,
                breakdown: PreviewData.paidWithoutHistory,
                addPayment: {},
                payBalance: {},
                resetBalance: {},
                viewHistory: {}
            )

            ParticipantBreakdownView(
                showPaymentsSection: true,
                breakdown: PreviewData.paidWithHistory,
                addPayment: {},
                payBalance: {},
                resetBalance: {},
                viewHistory: {}
            )
        }
        .padding()
    }
}

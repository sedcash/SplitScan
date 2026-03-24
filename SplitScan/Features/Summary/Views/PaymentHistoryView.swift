import SwiftUI

struct PaymentHistoryView: View {
    enum Metrics {
        static let closeButtonSize: CGFloat = 28
        static let containerCornerRadius: CGFloat = 28
        static let containerMaxHeight: CGFloat = 500
        static let containerMaxWidth: CGFloat = 540
        static let containerPadding: CGFloat = 24
        static let rowCornerRadius: CGFloat = 16
        static let rowPadding: CGFloat = 16
        static let rowSpacing: CGFloat = 12
    }

    let records: [PaymentRecord]
    let totalPaid: Money

    let dismissAction: () -> Void
    let deleteRecord: (UUID) -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            header

            if records.isEmpty {
                emptyState
            } else {
                paymentList
            }

            Divider()

            MoneyLabel(
                title: "Total Paid",
                titleFont: .title3.weight(.semibold),
                value: totalPaid.formatted(),
                valueFont: .title3.weight(.semibold),
                valueColor: .green
            )
        }
        .padding(Metrics.containerPadding)
        .frame(maxWidth: Metrics.containerMaxWidth, maxHeight: Metrics.containerMaxHeight)
        .background(
            RoundedRectangle(cornerRadius: Metrics.containerCornerRadius)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
        )
        .padding(.horizontal, Metrics.containerPadding)
    }

    private var header: some View {
        HStack {
            Text("Payment History")
                .font(.title2.weight(.semibold))

            Spacer()

            Button(action: dismissAction) {
                Image(systemName: "xmark")
                    .foregroundStyle(.secondary)
                    .frame(width: Metrics.closeButtonSize, height: Metrics.closeButtonSize)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Text("No payments yet")
                .font(.headline)

            Text("Payments added for this participant will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var paymentList: some View {
        ScrollView {
            LazyVStack(spacing: Metrics.rowSpacing) {
                ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                    paymentRow(index: index, record: record)
                }
            }
        }
    }

    private func paymentRow(index: Int, record: PaymentRecord) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            MoneyLabel(
                title: "Payment \(index + 1)",
                titleFont: .subheadline,
                titleColor: .secondary,
                value: record.amount.formatted(),
                valueFont: .title3.weight(.semibold),
                valueColor: .green
            )

            Text(record.paidAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(Metrics.rowPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Metrics.rowCornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
        .swipeActions {
            Button(role: .destructive) {
                deleteRecord(record.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

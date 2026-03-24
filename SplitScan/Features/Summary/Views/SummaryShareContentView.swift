import SwiftUI

struct SummaryShareContentView: View {
    enum Metrics {
        static let contentPadding: CGFloat = 24
        static let sectionSpacing: CGFloat = 24
        static let totalsCornerRadius: CGFloat = 16
        static let headerCornerRadius: CGFloat = 20
    }

    let receipt: Receipt
    let breakdowns: [ParticipantBreakdown]

    var body: some View {
        VStack(spacing: Metrics.sectionSpacing) {
            header

            ForEach(breakdowns, id: \.id) { breakdown in
                ParticipantBreakdownView(
                    showPaymentsSection: false,
                    breakdown: breakdown,
                    addPayment: {},
                    payBalance: {},
                    resetBalance: {},
                    viewHistory: {}
                )
            }

            totals
        }
        .padding(Metrics.contentPadding)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGray6))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(receipt.merchantName)
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(.white)

            Text(receipt.date.formatted(date: .abbreviated, time: .shortened))
                .font(.title3)
                .foregroundStyle(.white.opacity(0.95))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Metrics.headerCornerRadius)
                .fill(Color.blue)
        )
    }

    private var totals: some View {
        VStack(spacing: 12) {
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
                Text(receipt.totals.grandTotal.formatted())
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(.white)

                Spacer()

                let personCountText = receipt.participants.count == 1 ? "Person" : "People"
                Text("\(receipt.participants.count) \(personCountText)")
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
                    text: receipt.paidStatusText,
                    textColor: receipt.isPaid ? .green : .orange
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

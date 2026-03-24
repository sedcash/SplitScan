import SwiftUI

struct ShareSummaryView: View {
    let receipt: Receipt
    let breakdowns: [ParticipantBreakdown]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(receipt.merchantName)
                .font(.title.weight(.semibold))

            Text(receipt.date.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            ForEach(breakdowns, id: \.id) { breakdown in
                HStack {
                    Text(breakdown.participant.name)
                    Spacer()
                    Text(breakdown.total.formatted())
                        .fontWeight(.semibold)
                }
            }

            Divider()

            HStack {
                Text("Total Bill")
                    .font(.headline)
                Spacer()
                Text(receipt.totals.grandTotal.formatted())
                    .font(.headline)
            }
        }
        .padding(24)
        .frame(width: 360)
        .background(Color.white)
    }
}

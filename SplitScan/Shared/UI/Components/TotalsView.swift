import SwiftUI

struct TotalsView: View {
    let totals: ReceiptTotals

    var showsDividerBeforeTotal: Bool
    var showsTotal: Bool

    init(
        totals: ReceiptTotals,
        showsTotal: Bool = true,
        showsDividerBeforeTotal: Bool = true
    ) {
        self.totals = totals
        self.showsTotal = showsTotal
        self.showsDividerBeforeTotal = showsDividerBeforeTotal
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            MoneyLabel(title: "Subtotal", value: totals.subtotal.formatted())

            if let tax = totals.tax {
                MoneyLabel(title: "Tax", value: tax.formatted())
            }

            if let tip = totals.tip {
                MoneyLabel(title: "Tip", value: tip.formatted())
            }

            if let serviceFee = totals.serviceFee {
                MoneyLabel(title: "Service Fee", value: serviceFee.formatted())
            }

            if showsTotal {
                if showsDividerBeforeTotal {
                    Divider()
                }

                MoneyLabel(
                    title: "Total",
                    titleFont: .title3.weight(.semibold),
                    value: totals.grandTotal.formatted(),
                    valueFont: .title3.weight(.semibold)
                )
            }
        }
        .padding()
    }
}

import SwiftUI

struct ItemView: View {
    let title: String
    let amount: String
    let quantity: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            MoneyLabel(title: title, value: amount)
            Text("Qty: \(quantity)")
        }
    }
}

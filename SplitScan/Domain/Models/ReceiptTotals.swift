import Foundation

struct ReceiptTotals: Codable, Hashable, Sendable {
    
    var grandTotal: Money
    var serviceFee: Money?
    var subtotal: Money
    var tax: Money?
    var tip: Money?

    init(
        grandTotal: Money = .zeroUSD,
        serviceFee: Money? = nil,
        subtotal: Money = .zeroUSD,
        tax: Money? = nil,
        tip: Money? = nil
    ) {
        self.grandTotal = grandTotal
        self.serviceFee = serviceFee
        self.subtotal = subtotal
        self.tax = tax
        self.tip = tip
    }

}

import Foundation

enum ReceiptRoute: Hashable, Equatable {
    case history
    case scan
    case receiptDetails(Receipt)
    case assignItems(Receipt)
    case summary(receipt: Receipt, mode: SummaryMode)
    case savedReceiptDetail(UUID)
}

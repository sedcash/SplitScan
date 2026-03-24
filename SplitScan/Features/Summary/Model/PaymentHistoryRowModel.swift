import Foundation

struct PaymentHistoryRowModel: Identifiable, Hashable {
    let amountText: String
    let id: UUID
    let subtitleText: String
    let title: String
}

import Foundation

struct ReceiptListRowModel: Hashable, Identifiable, Sendable {
    let id: UUID
    let date: Date
    let imagePath: String?
    let merchantName: String
    let paidStatusText: String
    let participantCount: Int
    let paymentStatus: PaymentStatus
    let total: Money

    init(
        id: UUID,
        date: Date,
        imagePath: String?,
        merchantName: String,
        paidStatusText: String,
        participantCount: Int,
        paymentStatus: PaymentStatus,
        total: Money
    ) {
        self.id = id
        self.date = date
        self.imagePath = imagePath
        self.merchantName = merchantName
        self.paidStatusText = paidStatusText
        self.participantCount = participantCount
        self.paymentStatus = paymentStatus
        self.total = total
    }

    init(receipt: Receipt) {
        self.init(
            id: receipt.id,
            date: receipt.date,
            imagePath: receipt.imagePath,
            merchantName: receipt.merchantName,
            paidStatusText: receipt.paidStatusText,
            participantCount: receipt.participants.count,
            paymentStatus: receipt.paymentStatus,
            total: receipt.totals.grandTotal
        )
    }
}

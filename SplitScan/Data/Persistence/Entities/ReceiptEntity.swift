import Foundation
import SwiftData

@Model
final class ReceiptEntity {
    var currencyCode: String
    var date: Date

    @Attribute(.unique) var id: UUID
    var imagePath: String?

    @Relationship(deleteRule: .cascade, inverse: \ReceiptItemEntity.receipt)
    var items: [ReceiptItemEntity]

    var merchantName: String

    @Relationship(deleteRule: .cascade, inverse: \ParticipantEntity.receipt)
    var participants: [ParticipantEntity]

    @Relationship(deleteRule: .cascade)
    var paymentRecords: [PaymentRecordEntity]

    var serviceFeeMinor: Int?
    var subtotalMinor: Int?
    var taxMinor: Int?
    var tipMinor: Int?
    var totalMinor: Int?

    init(
        currencyCode: String = "USD",
        date: Date,
        id: UUID = UUID(),
        imagePath: String? = nil,
        items: [ReceiptItemEntity] = [],
        participants: [ParticipantEntity] = [],
        paymentRecords: [PaymentRecordEntity] = [],
        merchantName: String,
        serviceFeeMinor: Int? = nil,
        subtotalMinor: Int? = nil,
        taxMinor: Int? = nil,
        tipMinor: Int? = nil,
        totalMinor: Int? = nil
    ) {
        self.currencyCode = currencyCode
        self.date = date
        self.id = id
        self.imagePath = imagePath
        self.items = items
        self.participants = participants
        self.paymentRecords = paymentRecords
        self.merchantName = merchantName
        self.serviceFeeMinor = serviceFeeMinor
        self.subtotalMinor = subtotalMinor
        self.taxMinor = taxMinor
        self.tipMinor = tipMinor
        self.totalMinor = totalMinor
    }
}

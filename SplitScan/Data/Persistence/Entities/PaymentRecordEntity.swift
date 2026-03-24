import Foundation
import SwiftData

@Model
final class PaymentRecordEntity {
    
    var amountMinor: Int
    var currencyCode: String
    var id: UUID
    var paidAt: Date
    var participantID: UUID

    init(
        amountMinor: Int,
        currencyCode: String,
        id: UUID = UUID(),
        paidAt: Date,
        participantID: UUID
    ) {
        self.amountMinor = amountMinor
        self.currencyCode = currencyCode
        self.id = id
        self.paidAt = paidAt
        self.participantID = participantID
    }

    func toModel() -> PaymentRecord {
        PaymentRecord(
            amount: Money(minorUnits: amountMinor, currencyCode: currencyCode),
            id: id,
            paidAt: paidAt,
            participantID: participantID
        )
    }

    static func fromModel(_ model: PaymentRecord) -> PaymentRecordEntity {
        PaymentRecordEntity(
            amountMinor: model.amount.minorUnits,
            currencyCode: model.amount.currencyCode,
            id: model.id,
            paidAt: model.paidAt,
            participantID: model.participantID
        )
    }
    
}

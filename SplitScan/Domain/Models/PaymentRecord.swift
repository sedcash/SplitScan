import Foundation

struct PaymentRecord: Identifiable, Codable, Hashable, Sendable {
    
    var amount: Money
    var id: UUID
    var paidAt: Date
    var participantID: UUID

    init(
        amount: Money,
        id: UUID = UUID(),
        paidAt: Date = .now,
        participantID: UUID
    ) {
        self.amount = amount
        self.id = id
        self.paidAt = paidAt
        self.participantID = participantID
    }
    
}

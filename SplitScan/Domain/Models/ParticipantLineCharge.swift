import Foundation

struct ParticipantLineCharge: Hashable, Identifiable, Sendable {

    var amount: Money
    var displaySuffix: String?
    var id: UUID { itemID }
    var itemID: UUID
    var itemName: String

}

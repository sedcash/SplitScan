import Foundation

struct ItemAssignment: Codable, Hashable, Identifiable, Sendable {
    
    var denominator: Int
    var id: UUID
    var itemID: UUID
    var numerator: Int
    var participantID: UUID

    var fraction: Double {
        guard denominator != 0 else { return 0 }
        return Double(numerator) / Double(denominator)
    }

    init(
        denominator: Int = 1,
        id: UUID = UUID(),
        itemID: UUID,
        numerator: Int = 1,
        participantID: UUID
    ) {
        self.denominator = denominator
        self.id = id
        self.itemID = itemID
        self.numerator = numerator
        self.participantID = participantID
    }

}

import Foundation
import SwiftData

@Model
final class ItemAssignmentEntity {
    @Attribute(.unique) var id: UUID
    var numerator: Int
    var denominator: Int
    var item: ReceiptItemEntity?
    var participant: ParticipantEntity?

    init(
        id: UUID = UUID(),
        numerator: Int,
        denominator: Int,
        item: ReceiptItemEntity? = nil,
        participant: ParticipantEntity? = nil
    ) {
        self.id = id
        self.numerator = numerator
        self.denominator = denominator
        self.item = item
        self.participant = participant
    }
}

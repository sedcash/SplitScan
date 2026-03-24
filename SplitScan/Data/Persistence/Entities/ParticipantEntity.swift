import Foundation
import SwiftData

@Model
final class ParticipantEntity {
    @Relationship(deleteRule: .cascade, inverse: \ItemAssignmentEntity.participant)
    var assignments: [ItemAssignmentEntity]

    var colorHex: String

    @Attribute(.unique) var id: UUID
    var name: String
    var receipt: ReceiptEntity?

    init(
        assignments: [ItemAssignmentEntity] = [],
        colorHex: String,
        id: UUID = UUID(),
        name: String,
        receipt: ReceiptEntity? = nil
    ) {
        self.assignments = assignments
        self.colorHex = colorHex
        self.id = id
        self.name = name
        self.receipt = receipt
    }
}

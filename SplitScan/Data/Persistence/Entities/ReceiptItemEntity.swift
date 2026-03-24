import Foundation
import SwiftData

@Model
final class ReceiptItemEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var quantity: Int
    var totalMinor: Int
    var receipt: ReceiptEntity?

    @Relationship(deleteRule: .cascade, inverse: \ItemAssignmentEntity.item)
    var assignments: [ItemAssignmentEntity]

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Int,
        totalMinor: Int,
        receipt: ReceiptEntity? = nil,
        assignments: [ItemAssignmentEntity] = []
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.totalMinor = totalMinor
        self.receipt = receipt
        self.assignments = assignments
    }
}

import Foundation
import SwiftData

struct SwiftDataReceiptLocalStore: ReceiptLocalStoreProtocol {
    func deleteReceipt(id: UUID, in context: ModelContext) throws {
        let descriptor = FetchDescriptor<ReceiptEntity>(
            predicate: #Predicate<ReceiptEntity> { $0.id == id }
        )

        guard let receipt = try context.fetch(descriptor).first else {
            return
        }

        context.delete(receipt)
        try context.save()
    }

    func fetchReceipt(id: UUID, in context: ModelContext) throws -> ReceiptEntity? {
        let descriptor = FetchDescriptor<ReceiptEntity>(
            predicate: #Predicate<ReceiptEntity> { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    func fetchReceipts(in context: ModelContext) throws -> [ReceiptEntity] {
        let descriptor = FetchDescriptor<ReceiptEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func saveReceipt(_ entity: ReceiptEntity, in context: ModelContext) throws {
        let receiptID = entity.id

        let descriptor = FetchDescriptor<ReceiptEntity>(
            predicate: #Predicate<ReceiptEntity> { $0.id == receiptID }
        )

        if let existing = try context.fetch(descriptor).first {
            context.delete(existing)
            try context.save()
        }

        context.insert(entity)
        try context.save()
    }
}

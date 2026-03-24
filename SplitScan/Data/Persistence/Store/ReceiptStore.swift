import Foundation
import SwiftData

protocol ReceiptLocalStoreProtocol {
    func deleteReceipt(id: UUID, in context: ModelContext) throws
    func fetchReceipt(id: UUID, in context: ModelContext) throws -> ReceiptEntity?
    func fetchReceipts(in context: ModelContext) throws -> [ReceiptEntity]
    func saveReceipt(_ entity: ReceiptEntity, in context: ModelContext) throws
}

import Foundation
import SwiftData

final class ReceiptRepository: ReceiptRepositoryProtocol {
    private let imageStore: ReceiptImageStore
    private let localStore: ReceiptLocalStoreProtocol
    private let modelContext: ModelContext

    init(
        imageStore: ReceiptImageStore,
        localStore: ReceiptLocalStoreProtocol,
        modelContext: ModelContext
    ) {
        self.imageStore = imageStore
        self.localStore = localStore
        self.modelContext = modelContext
    }

    func deleteReceipt(id: UUID) throws {
        try localStore.deleteReceipt(id: id, in: modelContext)
    }

    func fetchReceipt(id: UUID) throws -> ReceiptEntity? {
        try localStore.fetchReceipt(id: id, in: modelContext)
    }

    func fetchReceipts() throws -> [ReceiptEntity] {
        try localStore.fetchReceipts(in: modelContext)
    }

    func saveReceipt(_ receipt: Receipt) throws {
        let entity = ReceiptEntityMapper.makeReceiptEntity(from: receipt)
        try localStore.saveReceipt(entity, in: modelContext)
    }
}

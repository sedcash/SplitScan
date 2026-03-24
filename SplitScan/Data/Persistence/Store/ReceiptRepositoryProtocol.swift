import Foundation

protocol ReceiptRepositoryProtocol {
    
    func deleteReceipt(id: UUID) throws
    func fetchReceipt(id: UUID) throws -> ReceiptEntity?
    func fetchReceipts() throws -> [ReceiptEntity]
    func saveReceipt(_ receipt: Receipt) throws
    
}

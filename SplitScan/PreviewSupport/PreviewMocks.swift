import Foundation
import UIKit
import SwiftData
import AVFoundation

struct PreviewCameraAuthorization: CameraAuthorizing {
    func requestAccess() async -> Bool { true }
}

@MainActor
final class PreviewCameraService: CameraServicing {
    func capturePhoto() async throws -> UIImage {
        UIImage(systemName: "doc.text.viewfinder")!
    }
    
    
    let session = AVCaptureSession()
    var lastCapturedImage: UIImage?
    var isRunning: Bool = false

    func configureIfNeeded() async throws {}
    func start() { isRunning = true }
    func stop() { isRunning = false }
    
}

struct PreviewOCRService: OCRService {
    
    func recognizeText(in image: UIImage) async throws -> OCRResult {
        PreviewData.parsedOCRResult
    }
    
}

struct PreviewReceiptParser: ReceiptParsing {
    
    func parse(ocr: OCRResult, currencyCode: String) -> Receipt {
        PreviewData.receipt
    }
    
}

final class PreviewReceiptRepository: ReceiptRepositoryProtocol {

    var receipts: [ReceiptEntity] = []

    init(receipts: [ReceiptEntity] = []) {
        self.receipts = receipts
    }

    func saveReceipt(_ receipt: Receipt) throws {
        let entity = ReceiptEntityMapper.makeReceiptEntity(from: receipt)
        receipts.removeAll { $0.id == entity.id }
        receipts.append(entity)
    }

    func fetchReceipts() throws -> [ReceiptEntity] {
        receipts.sorted { $0.date > $1.date }
    }

    func fetchReceipt(id: UUID) throws -> ReceiptEntity? {
        receipts.first(where: { $0.id == id })
    }

    func deleteReceipt(id: UUID) throws {
        receipts.removeAll { $0.id == id }
    }
    
}

struct PreviewReceiptImageStore {
    
    func sampleImage() -> UIImage {
        UIImage(systemName: "receipt") ?? UIImage()
    }
    
}

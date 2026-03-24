import SwiftUI

@MainActor
struct ViewModelFactory {
    let cameraAuthorization: CameraAuthorizing
    let cameraService: CameraServicing
    let ocrService: OCRService
    let receiptParser: ReceiptParsing
    let splitCalculator: SplitCalculating
    let receiptRepository: ReceiptRepositoryProtocol
    let receiptImageStore: ReceiptImageStore

    func makeScanReceiptViewModel() -> ScanReceiptViewModel {
        ScanReceiptViewModel(
            cameraAuthorization: cameraAuthorization,
            cameraService: cameraService,
            ocrService: ocrService,
            receiptParser: receiptParser,
            receiptImageStore: receiptImageStore
        )
    }

    func makeReceiptDetailsViewModel(receipt: Receipt) -> ReceiptDetailsViewModel {
        ReceiptDetailsViewModel(receipt: receipt)
    }

    func makeAssignItemsViewModel(
        receipt: Receipt,
    ) -> AssignItemsViewModel {
        AssignItemsViewModel(receipt: receipt)
    }

    func makeSummaryViewModel(
        receipt: Receipt,
        mode: SummaryMode
    ) -> SummaryViewModel {
        SummaryViewModel(
            receipt: receipt,
            calculator: splitCalculator,
            mode: mode,
            repository: receiptRepository
        )
    }

    func makeReceiptHistoryViewModel() -> ReceiptHistoryViewModel {
        ReceiptHistoryViewModel(repository: receiptRepository)
    }
    
    func makeSavedReceiptViewModel(receiptID: UUID) -> SavedReceiptDetailViewModel {
        SavedReceiptDetailViewModel(
            receiptID: receiptID,
            repository: receiptRepository
        )
    }
}

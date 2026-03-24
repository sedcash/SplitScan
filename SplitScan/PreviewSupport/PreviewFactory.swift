import Foundation

@MainActor
enum PreviewFactory {

    static func makeScanReceiptViewModel() -> ScanReceiptViewModel {
        ScanReceiptViewModel(
            cameraAuthorization: PreviewCameraAuthorization(),
            cameraService: PreviewCameraService(),
            ocrService: PreviewOCRService(),
            receiptParser: PreviewReceiptParser(),
            receiptImageStore: ReceiptImageStore()
        )
    }

    static func makeReceiptDetailsViewModel() -> ReceiptDetailsViewModel {
        ReceiptDetailsViewModel(receipt: PreviewData.receipt)
    }

    static func makeAssignItemsViewModel() -> AssignItemsViewModel {
        AssignItemsViewModel(receipt: PreviewData.receipt)
    }

    static func makeAssignItemsEqualSplitViewModel() -> AssignItemsViewModel {
        AssignItemsViewModel(
            receipt: PreviewData.receipt
        )
    }

    static func makeSummaryViewModel() -> SummaryViewModel {
        SummaryViewModel(
            receipt: PreviewData.receipt,
            calculator: SplitCalculator(),
            mode: .edit,
            repository: PreviewReceiptRepository()
        )
    }

    static func makeReceiptHistoryViewModel() -> ReceiptHistoryViewModel {
        let repo = PreviewReceiptRepository(
            receipts: [
                ReceiptEntityMapper.makeReceiptEntity(from: PreviewData.receipt)
            ]
        )

        return ReceiptHistoryViewModel(repository: repo)
    }

    static func makeSavedReceiptDetailViewModel() -> SavedReceiptDetailViewModel {
        let entity = ReceiptEntityMapper.makeReceiptEntity(from: PreviewData.receipt)
        
        let repo = PreviewReceiptRepository(receipts: [entity])

        return SavedReceiptDetailViewModel(
            receiptID: entity.id,
            repository: repo
        )
    }
}

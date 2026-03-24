import Foundation
import SwiftData

@MainActor
struct AppEnvironment {

    // MARK: Services
    let cameraAuthorization: CameraAuthorizing
    let cameraService: CameraServicing
    let ocrService: OCRService
    let receiptParser: ReceiptParsing
    let splitCalculator: SplitCalculating

    // MARK: Persistence
    let modelContext: ModelContext
    let receiptLocalStore: ReceiptLocalStoreProtocol
    let receiptImageStore: ReceiptImageStore

    // MARK: Repository
    let receiptRepository: ReceiptRepositoryProtocol

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Services
        self.cameraAuthorization = CameraAuthorizationService()
        self.cameraService = CameraService()
        self.ocrService = VisionOCRService()
        self.receiptParser = HeuristicReceiptParser()
        self.splitCalculator = SplitCalculator()

        // Persistence
        self.receiptLocalStore = SwiftDataReceiptLocalStore()
        self.receiptImageStore = ReceiptImageStore()

        // Repository
        self.receiptRepository = ReceiptRepository(
            imageStore: receiptImageStore,
            localStore: receiptLocalStore,
            modelContext: modelContext
        )
    }

    var viewModelFactory: ViewModelFactory {
        ViewModelFactory(
            cameraAuthorization: cameraAuthorization,
            cameraService: cameraService,
            ocrService: ocrService,
            receiptParser: receiptParser,
            splitCalculator: splitCalculator,
            receiptRepository: receiptRepository,
            receiptImageStore: receiptImageStore
        )
    }
}

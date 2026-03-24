import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class ScanReceiptViewModel {
    enum Output {
        case cancel
        case receiptDetails(Receipt)
    }

    // MARK: - Dependencies

    private let cameraAuthorization: CameraAuthorizing
    private let cameraService: CameraServicing
    private let ocrService: OCRService
    private let receiptParser: ReceiptParsing
    private let receiptImageStore: ReceiptImageStore

    // MARK: - Public State

    var capturedImage: UIImage?
    var errorMessage: String?
    var hasPreparedCamera = false
    var isPreparingCamera = false
    var isProcessingImage = false
    var onOutput: ((Output) -> Void)?
    var parsed: Receipt?

    // MARK: - Init

    init(
        cameraAuthorization: CameraAuthorizing,
        cameraService: CameraServicing,
        ocrService: OCRService,
        receiptParser: ReceiptParsing,
        receiptImageStore: ReceiptImageStore
    ) {
        self.cameraAuthorization = cameraAuthorization
        self.cameraService = cameraService
        self.ocrService = ocrService
        self.receiptParser = receiptParser
        self.receiptImageStore = receiptImageStore
    }

    // MARK: - Public Methods

    func cancelButtonTapped() {
        clear()
        onOutput?(.cancel)
    }

    func capturePhoto() async {
        do {
            let image = try await cameraService.capturePhoto()
            capturedImage = image
            await processImage(image)
        } catch {
            errorMessage = "Failed to capture photo: \(error.localizedDescription)"
        }
    }

    func clear() {
        capturedImage = nil
        parsed = nil
        errorMessage = nil
        isProcessingImage = false
        hasPreparedCamera = false
        stopCamera()
    }

    func prepareCamera() async {
        guard !hasPreparedCamera else {
            cameraService.start()
            return
        }

        isPreparingCamera = true
        defer { isPreparingCamera = false }

        let granted = await cameraAuthorization.requestAccess()
        guard granted else {
            errorMessage = "Camera permission denied."
            return
        }

        do {
            try await cameraService.configureIfNeeded()
            cameraService.start()
            hasPreparedCamera = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func processPickedImage(_ image: UIImage) async {
        await processImage(image)
    }

    func stopCamera() {
        cameraService.stop()
    }

    // MARK: - Private Methods

    private func processImage(_ image: UIImage) async {
        isProcessingImage = true
        defer { isProcessingImage = false }

        do {
            let path = try receiptImageStore.save(image)
            let ocr = try await ocrService.recognizeText(in: image)

            var parsedReceipt = receiptParser.parse(ocr: ocr, currencyCode: "USD")
            parsedReceipt.imagePath = path

            parsed = parsedReceipt
            capturedImage = image

            onOutput?(.receiptDetails(parsedReceipt))
        } catch {
            errorMessage = "Failed to scan receipt: \(error.localizedDescription)"
        }
    }
}

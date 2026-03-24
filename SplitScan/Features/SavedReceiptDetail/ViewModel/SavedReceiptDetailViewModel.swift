import Foundation
import Observation

@MainActor
@Observable
final class SavedReceiptDetailViewModel {
    enum Output {
        case back
        case retakePhoto
        case summary(Receipt)
    }

    // MARK: - Dependencies

    private let repository: ReceiptRepositoryProtocol

    // MARK: - Public State

    var errorMessage: String?
    var isLoading = false
    var onOutput: ((Output) -> Void)?
    var savedReceipt: Receipt?

    let receiptID: UUID

    // MARK: - Derived

    var participants: [Participant] {
        savedReceipt?.participants ?? []
    }

    // MARK: - Init

    init(
        receiptID: UUID,
        repository: ReceiptRepositoryProtocol
    ) {
        self.receiptID = receiptID
        self.repository = repository
    }

    // MARK: - Public Methods

    func deleteReceiptTapped() {
        deleteReceipt()
        onOutput?(.back)
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            savedReceipt = try repository.fetchReceipt(id: receiptID)?.toReceipt()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func retakePhotoTapped() {
        onOutput?(.retakePhoto)
    }

    func viewPaymentSummaryTapped() {
        guard let savedReceipt else { return }
        onOutput?(.summary(savedReceipt))
    }

    // MARK: - Private Methods

    private func deleteReceipt() {
        do {
            try repository.deleteReceipt(id: receiptID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

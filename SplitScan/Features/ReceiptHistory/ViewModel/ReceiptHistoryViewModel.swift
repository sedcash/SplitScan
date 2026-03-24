import Foundation
import Observation
import SwiftData

enum ReceiptFilter: String, CaseIterable {
    case all
    case paid
    case unpaid
}

@MainActor
@Observable
final class ReceiptHistoryViewModel {
    enum Output {
        case openReceipt(UUID)
        case startScan
    }

    // MARK: - Dependencies

    private let repository: ReceiptRepositoryProtocol

    // MARK: - Private State

    private var receiptEntities: [ReceiptEntity] = []

    // MARK: - Public State

    var errorMessage: String?
    var onOutput: ((Output) -> Void)?
    var rows: [ReceiptListRowModel] = []
    var searchText = ""
    var selectedFilter: ReceiptFilter = .all

    // MARK: - Derived

    var filteredRows: [ReceiptListRowModel] {
        let normalizedQuery = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return rows.filter { row in
            let matchesSearch: Bool
            if normalizedQuery.isEmpty {
                matchesSearch = true
            } else {
                matchesSearch =
                    row.merchantName.lowercased().contains(normalizedQuery) ||
                    row.paidStatusText.lowercased().contains(normalizedQuery) ||
                    row.total.formatted().lowercased().contains(normalizedQuery)
            }

            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .paid:
                matchesFilter = row.paymentStatus == .paid
            case .unpaid:
                matchesFilter = row.paymentStatus != .paid
            }

            return matchesSearch && matchesFilter
        }
    }

    // MARK: - Init

    init(repository: ReceiptRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func load() {
        do {
            receiptEntities = try repository.fetchReceipts()
            rows = receiptEntities.map { ReceiptListRowModel(receipt: $0.toReceipt()) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func receiptTapped(_ receiptID: UUID) {
        onOutput?(.openReceipt(receiptID))
    }

    func scanNewReceiptPressed() {
        onOutput?(.startScan)
    }
}

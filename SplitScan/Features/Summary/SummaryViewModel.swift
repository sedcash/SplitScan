import Foundation
import Observation

@MainActor
@Observable
final class SummaryViewModel {
    enum Output {
        case done
        case editAssignments(Receipt)
        case editItems(Receipt)
        case save(UUID)
        case share
    }

    // MARK: - Dependencies

    private let calculator: SplitCalculating
    private let repository: ReceiptRepositoryProtocol

    // MARK: - Public State

    var addPaymentAmountText = ""
    var errorMessage: String?
    var isSaving = false
    var mode: SummaryMode
    var onOutput: ((Output) -> Void)?
    var overlay: SummaryOverlay?
    var receipt: Receipt
    var selectedOnePersonTipParticipantID: UUID?
    var selectedTipPercent: Int?

    // MARK: - Init

    init(
        receipt: Receipt,
        calculator: SplitCalculating,
        mode: SummaryMode,
        repository: ReceiptRepositoryProtocol
    ) {
        self.receipt = receipt
        self.calculator = calculator
        self.mode = mode
        self.repository = repository

        if case .onePerson(let participantID) = receipt.tipPolicy {
            selectedOnePersonTipParticipantID = participantID
        }
    }

    // MARK: - Derived

    var breakdowns: [ParticipantBreakdown] {
        calculator.calculate(receipt: receipt)
    }

    var hasTip: Bool {
        receipt.totals.tip != nil
    }

    var isFullyPaid: Bool {
        !breakdowns.isEmpty && paidParticipantCount == breakdowns.count
    }

    var paidParticipantCount: Int {
        breakdowns.filter(\.isPaid).count
    }

    var quickTipPercents: [Int] {
        [15, 18, 20]
    }

    var tipAmountText: String {
        receipt.totals.tip?.decimalValue.description ?? "0.00"
    }

    var tipSplitMethodSelection: TipSplitMethodSelection {
        switch receipt.tipPolicy {
        case .proportional:
            .proportional
        case .equal:
            .equal
        case .onePerson:
            .onePerson
        }
    }

    // MARK: - Navigation

    func dismissOverlay() {
        overlay = nil
        addPaymentAmountText = ""
    }

    func doneTapped() {
        onOutput?(.done)
    }

    func editAssignmentsButtonTapped() {
        onOutput?(.editAssignments(receipt))
    }

    func editItemsButtonTapped() {
        onOutput?(.editItems(receipt))
    }

    func showAddPayment(for participantID: UUID) {
        addPaymentAmountText = ""
        overlay = .addPayment(participantID: participantID)
    }

    func showTipEditor() {
        overlay = .tipEditor
    }

    func viewHistory(for participantID: UUID) {
        overlay = .paymentHistory(participantID: participantID)
    }

    // MARK: - Payments

    func addPayment() {
        guard case .addPayment(let participantID) = overlay else { return }

        SummaryPaymentHelper.addPayment(
            to: &receipt,
            participantID: participantID,
            enteredAmountText: addPaymentAmountText,
            breakdowns: breakdowns
        )

        persistIfNeeded()
        dismissOverlay()
    }

    func deletePayment(_ paymentID: UUID, participantID: UUID) {
        SummaryPaymentHelper.deletePayment(
            from: &receipt,
            paymentID: paymentID,
            participantID: participantID
        )

        persistIfNeeded()
    }

    func getPayments(for participantID: UUID) -> [PaymentRecord] {
        SummaryPaymentHelper.payments(
            for: participantID,
            in: receipt
        )
    }

    func getPaymentsTotal(payments: [PaymentRecord]) -> Money {
        SummaryPaymentHelper.paymentsTotal(payments)
    }

    func payBalance(for participantID: UUID) {
        SummaryPaymentHelper.payRemainingBalance(
            for: participantID,
            in: &receipt,
            breakdowns: breakdowns
        )

        persistIfNeeded()
    }

    func resetBalance(for participantID: UUID) {
        SummaryPaymentHelper.resetBalance(
            for: participantID,
            in: &receipt
        )

        persistIfNeeded()
    }

    // MARK: - Tip Editing

    func clearTip() {
        selectedTipPercent = nil
        selectedOnePersonTipParticipantID = nil
        SummaryTipHelper.clearTip(on: &receipt)
        persistIfNeeded()
    }

    func selectQuickTipPercent(_ percent: Int) {
        selectedTipPercent = percent
        SummaryTipHelper.selectQuickTipPercent(percent, on: &receipt)
        persistIfNeeded()
    }

    func setOnePersonTipParticipant(_ participantID: UUID) {
        selectedOnePersonTipParticipantID = participantID
        SummaryTipHelper.setOnePersonTipParticipant(participantID, on: &receipt)
        persistIfNeeded()
    }

    func setTipSplitMethod(_ method: TipSplitMethodSelection) {
        selectedOnePersonTipParticipantID = SummaryTipHelper.setTipSplitMethod(
            method,
            selectedParticipantID: selectedOnePersonTipParticipantID,
            receipt: &receipt
        )

        persistIfNeeded()
    }

    func updateCustomTipAmount(_ text: String) {
        selectedTipPercent = nil
        SummaryTipHelper.updateCustomTipAmount(text, on: &receipt)
        persistIfNeeded()
    }

    // MARK: - Sharing

    func buildShareItems() async -> [Any] {
        do {
            let pdfURL = try await ShareSummaryPDFBuilder.makePDF(
                receipt: receipt,
                breakdowns: breakdowns
            )

            let text = ShareTextBuilder.make(receipt: receipt, breakdowns: breakdowns)
            return [pdfURL, text]
        } catch {
            errorMessage = error.localizedDescription

            let fallbackText = ShareTextBuilder.make(receipt: receipt, breakdowns: breakdowns)
            return fallbackText.isEmpty ? [] : [fallbackText]
        }
    }

    func buildShareText() -> String {
        ShareTextBuilder.make(receipt: receipt, breakdowns: breakdowns)
    }

    // MARK: - Persistence

    func saveTapped() async {
        guard mode == .edit else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            try repository.saveReceipt(receipt)
            onOutput?(.save(receipt.id))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private Methods

    private func persistIfNeeded() {
        guard mode == .saved else { return }

        do {
            try repository.saveReceipt(receipt)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

import Foundation
import Observation

@Observable
@MainActor
final class ReceiptDetailsViewModel {
    
    var activeSheet: EditSheetMode? {
        didSet {
            guard let activeSheet else { return }
            state = initialState(for: activeSheet)
            validationErrors = []
        }
    }
    var state: EditFormState = .addItem()
    
    var canContinue: Bool {
        !receipt.items.isEmpty
    }
    
    var receipt: Receipt
    
    var formattedDate: String {
        receipt.date.abbreviatedDateTime
    }
    
    enum Output {
        case assignments(Receipt)
        case retakePhoto
        case cancel
    }
    
    var onOutput: ((Output) -> Void)?
    
    var modalDestination: ReceiptDetailsModalDestination?
    
    var validationErrors: [ValidationError] = []
    
    init(receipt: Receipt) {
        self.receipt = receipt
    }
    
    func addItem(name: String, minorUnits: Int, quantity: Int = 1) {
        let item = ReceiptLineItem(
            name: name,
            price: Money(minorUnits: minorUnits),
            quantity: quantity
        )
        receipt.items.append(item)
        receipt.recalculateTotals()
    }
    
    func addItemTapped() {
        activeSheet = .addItem
    }
    
    func continueTapped() {
        guard canContinue else { return }
        onOutput?(.assignments(receipt))
    }
    
    func decrementItemQuantity(itemID: UUID) {
        guard let index = receipt.items.firstIndex(where: { $0.id == itemID }) else { return }
        
        if receipt.items[index].hasMoreThanOne {
            receipt.items[index].decrementQuantity()
            receipt.recalculateTotals()
        } else {
            removeItem(itemID: itemID)
        }
    }
    
    func dismissSheet() {
        activeSheet = nil
        validationErrors = []
    }
    
    func editItemTapped(_ item: ReceiptLineItem) {
        activeSheet = .editItem(itemID: item.id)
    }
    
    func editReceiptInfoTapped() {
        activeSheet = .editReceiptInfo
    }
    
    func incrementItemQuantity(itemID: UUID) {
        guard let index = receipt.items.firstIndex(where: { $0.id == itemID }) else { return }
        receipt.items[index].incrementQuantity()
        receipt.recalculateTotals()
    }
    
    func initialState(for mode: EditSheetMode) -> EditFormState {
        switch mode {
        case .editItem(let itemID):
            guard let item = receipt.items.first(where: { $0.id == itemID }) else {
                return .addItem()
            }
            
            return .editItem(
                itemName: item.name,
                priceText: item.price.decimalValue.description,
                quantityText: String(item.quantity)
            )
            
        case .editReceiptInfo:
            return .receiptInfo(
                merchantName: receipt.merchantName,
                date: receipt.date
            )
        default:
            return .addItem()
        }
    }
    
    func receiptImageButtonTapped() {
        if let path = receipt.imagePath, !path.isEmpty {
            modalDestination = .imagePreview(path: path)
        } else {
            modalDestination = .camera
        }
    }
    
    func removeItem(itemID: UUID) {
        receipt.items.removeAll { $0.id == itemID }
        receipt.recalculateTotals()
    }
    
    func retakePhotoTapped() {
        modalDestination = nil
        onOutput?(.retakePhoto)
    }
    
    func saveForm(mode: EditSheetMode) {
        switch mode {
        case .addItem:
            guard
                let price = Decimal(string: state.priceText),
                let quantity = Int(state.quantityText)
            else { return }
            
            addItem(
                name: state.itemName.trimmingCharacters(in: .whitespacesAndNewlines),
                minorUnits: price.minorUnits,
                quantity: quantity
            )
            
        case let .editItem(itemID):
            guard let price = Decimal(string: state.priceText) else { return }
            
            updateItemName(
                itemID: itemID,
                name: state.itemName.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            updateItemPrice(
                itemID: itemID,
                minorUnits: price.minorUnits
            )
            
        case .editReceiptInfo:
            updateDate(state.date)
            updateMerchantName(
                state.merchantName.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        case .addParticipant:
            break
        }
        
        activeSheet = nil
        validationErrors = []
    }
    
    func setTax(minorUnits: Int?) {
        if let minorUnits {
            receipt.totals.tax = Money(
                minorUnits: max(minorUnits, 0),
                currencyCode: receipt.currencyCode
            )
        } else {
            receipt.totals.tax = nil
        }
        receipt.recalculateTotals()
    }
    
    func setTip(minorUnits: Int?) {
        if let minorUnits {
            receipt.totals.tip = Money(
                minorUnits: max(minorUnits, 0),
                currencyCode: receipt.currencyCode
            )
        } else {
            receipt.totals.tip = nil
        }
        receipt.recalculateTotals()
    }
    
    func updateDate(_ date: Date) {
        receipt.date = date
    }
    
    func updateItemName(itemID: UUID, name: String) {
        guard let index = receipt.items.firstIndex(where: { $0.id == itemID }) else { return }
        receipt.items[index].name = name
    }
    
    func updateItemPrice(itemID: UUID, minorUnits: Int) {
        guard let index = receipt.items.firstIndex(where: { $0.id == itemID }) else { return }
        receipt.items[index].price.minorUnits = max(minorUnits, 0)
        receipt.recalculateTotals()
    }
    
    func updateMerchantName(_ name: String) {
        receipt.merchantName = name
    }
    
}



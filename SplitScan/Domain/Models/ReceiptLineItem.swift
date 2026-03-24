import Foundation

struct ReceiptLineItem: Codable, Hashable, Identifiable, Sendable {
    
    var id: UUID
    var name: String
    var price: Money
    var quantity: Int
    
    var hasMoreThanOne: Bool {
        quantity > 1
    }
    
    var totalPrice: Money {
        Money(minorUnits: quantity * price.minorUnits, currencyCode: price.currencyCode)
    }

    init(
        id: UUID = UUID(),
        name: String,
        price: Money,
        quantity: Int = 1
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
    }
    
    mutating func decrementQuantity() {
        guard hasMoreThanOne else { return }
        quantity -= 1
    }
    
    mutating func incrementQuantity() {
        quantity += 1
    }
    
}


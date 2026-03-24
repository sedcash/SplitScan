import Foundation

struct EditFormState: Equatable {
    
    var merchantName: String
    var date: Date
    var itemName: String
    var priceText: String
    var quantityText: String
    var name: String
    var color: String
    
    init(
        merchantName: String = "",
        date: Date = .now,
        itemName: String = "",
        priceText: String = "",
        quantityText: String = "1",
        name: String = "",
        color: String = "#2563EB"
    ) {
        self.merchantName = merchantName
        self.priceText = priceText
        self.itemName = itemName
        self.color = color
        self.name = name
        self.date = date
        self.quantityText = quantityText
    }
    
    static func receiptInfo(
        merchantName: String,
        date: Date
    ) -> EditFormState {
        EditFormState(
            merchantName: merchantName,
            date: date
        )
    }

    static func editItem(
        itemName: String,
        priceText: String,
        quantityText: String = "1"
    ) -> EditFormState {
        EditFormState(
            itemName: itemName,
            priceText: priceText,
            quantityText: quantityText
        )
    }

    static func addItem() -> EditFormState {
        EditFormState()
    }
    
    static func addParticipant(name: String, color: String) -> EditFormState {
        EditFormState(
            name: name,
            color: color
        )
    }
    
}

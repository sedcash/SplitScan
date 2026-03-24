import Foundation

struct Receipt: Codable, Hashable, Identifiable, Sendable, Equatable {
    
    var currencyCode: String
    var date: Date
    var id: UUID
    var imagePath: String?
    var items: [ReceiptLineItem]
    var merchantName: String
    var totals: ReceiptTotals
    var itemAssignments: [ItemAssignment]
    var participants: [Participant]
    var paymentRecords: [PaymentRecord]
    var tipPolicy: TipPolicy
    
    var paidCount: Int {
        paymentRecords
            .map(\.participantID)
            .reduce(into: Set<UUID>()) { $0.insert($1) }
            .count
    }
    
    var isPaid: Bool {
        participants.count > 0 && paidCount == participants.count
    }
    
    var isPartiallyPaid: Bool {
        paidCount > 0 && paidCount < participants.count
    }
    
    var paidStatusText: String {
        "\(paidCount)/\(participants.count) Paid"
    }
    
    var paymentStatus: PaymentStatus {
        if isPaid {
            return .paid
        } else if isPartiallyPaid {
            return .partial
        } else {
            return .unpaid
        }
    }

    init(
        currencyCode: String = "USD",
        date: Date = .now,
        id: UUID = UUID(),
        imagePath: String? = nil,
        items: [ReceiptLineItem] = [],
        merchantName: String = "Untitled",
        totals: ReceiptTotals = .init(),
        participants: [Participant] = [],
        paymentRecords: [PaymentRecord] = [],
        itemAssignments: [ItemAssignment] = [],
        tipPolicy: TipPolicy = .equal
    ) {
        self.currencyCode = currencyCode
        self.date = date
        self.id = id
        self.imagePath = imagePath
        self.items = items
        self.merchantName = merchantName
        self.totals = totals
        self.participants = participants
        self.paymentRecords = paymentRecords
        self.tipPolicy = tipPolicy
        self.itemAssignments = itemAssignments
    }
    
    mutating func recalculateTotals() {
        let subtotalMinorUnits = items.reduce(0) { partialResult, item in
            partialResult + item.totalPrice.minorUnits
        }
        
        let taxMinorUnits = totals.tax?.minorUnits ?? 0
        let tipMinorUnits = totals.tip?.minorUnits ?? 0
        let serviceFeeMinorUnits = totals.serviceFee?.minorUnits ?? 0
        
        totals.subtotal = Money(
            minorUnits: subtotalMinorUnits,
            currencyCode: currencyCode
        )
        
        totals.grandTotal = Money(
            minorUnits: subtotalMinorUnits + taxMinorUnits + tipMinorUnits + serviceFeeMinorUnits,
            currencyCode: currencyCode
        )
    }
    
    mutating func updateTipPolicy(_ tipPolicy: TipPolicy) {
        self.tipPolicy = tipPolicy
    }

}

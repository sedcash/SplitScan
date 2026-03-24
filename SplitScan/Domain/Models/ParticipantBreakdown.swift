import Foundation

struct ParticipantBreakdown: Identifiable, Hashable, Sendable {
    
    var amountPaid: Money
    var itemCount: Int
    var lastPayment: PaymentRecord?
    var lines: [ParticipantLineCharge]
    var participant: Participant
    var totals: ReceiptTotals

    var id: UUID { participant.id }

    var isPaid: Bool {
        amountPaid.minorUnits >= total.minorUnits
    }
    
    var total: Money {
        totals.grandTotal
    }

    var paidProgress: Double {
        guard total.minorUnits > 0 else { return 1 }
        return min(
            max(Double(amountPaid.minorUnits) / Double(total.minorUnits), 0),
            1
        )
    }
    
    var paidProgressString: String {
        String(format: "%.1f%%", paidProgress * 100)
    }

    var paymentStatus: PaymentStatus {
        if total.minorUnits <= 0 {
            return .paid
        }
        if amountPaid.minorUnits >= total.minorUnits {
            return .paid
        }
        if amountPaid.minorUnits > 0 {
            return .partial
        }
        return .unpaid
    }

    var remainingBalance: Money {
        Money(
            minorUnits: max(total.minorUnits - amountPaid.minorUnits, 0),
            currencyCode: total.currencyCode
        )
    }
    
    var lastDateString: String {
        guard let lastPaidAt = lastPayment?.paidAt else { return "No payments made yet" }
        
        if paymentStatus == .paid {
           return "Paid on \(DateFormatter.paymentDateFormatter.string(from: lastPaidAt))"
                
        }
        return "Last payment on \(DateFormatter.paymentDateFormatter.string(from: lastPaidAt))"
    }
    
}

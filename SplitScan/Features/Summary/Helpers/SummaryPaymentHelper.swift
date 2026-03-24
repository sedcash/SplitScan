import Foundation

enum SummaryPaymentHelper {
    static func addPayment(
        to receipt: inout Receipt,
        participantID: UUID,
        enteredAmountText: String,
        breakdowns: [ParticipantBreakdown]
    ) {
        guard let decimal = Decimal(string: enteredAmountText), decimal > 0 else { return }

        let breakdown = breakdowns.first(where: { $0.participant.id == participantID })
        let remainingMinor = breakdown?.remainingBalance.minorUnits ?? 0
        let enteredMinor = decimal.minorUnits
        let appliedMinor = min(enteredMinor, remainingMinor)

        guard appliedMinor > 0 else { return }

        receipt.paymentRecords.append(
            PaymentRecord(
                amount: Money(
                    minorUnits: appliedMinor,
                    currencyCode: receipt.currencyCode
                ),
                paidAt: .now,
                participantID: participantID
            )
        )
    }

    static func deletePayment(
        from receipt: inout Receipt,
        paymentID: UUID,
        participantID: UUID
    ) {
        receipt.paymentRecords.removeAll {
            $0.id == paymentID && $0.participantID == participantID
        }
    }

    static func payRemainingBalance(
        for participantID: UUID,
        in receipt: inout Receipt,
        breakdowns: [ParticipantBreakdown]
    ) {
        guard let breakdown = breakdowns.first(where: { $0.participant.id == participantID }) else {
            return
        }

        let remainingMinor = breakdown.remainingBalance.minorUnits
        guard remainingMinor > 0 else { return }

        receipt.paymentRecords.append(
            PaymentRecord(
                amount: Money(
                    minorUnits: remainingMinor,
                    currencyCode: receipt.currencyCode
                ),
                paidAt: .now,
                participantID: participantID
            )
        )
    }

    static func payments(
        for participantID: UUID,
        in receipt: Receipt
    ) -> [PaymentRecord] {
        receipt.paymentRecords.filter { $0.participantID == participantID }
    }

    static func paymentsTotal(_ payments: [PaymentRecord]) -> Money {
        payments.reduce(into: .zeroUSD) { accumulator, payment in
            accumulator.minorUnits += payment.amount.minorUnits
        }
    }

    static func resetBalance(
        for participantID: UUID,
        in receipt: inout Receipt
    ) {
        receipt.paymentRecords.removeAll { $0.participantID == participantID }
    }
}

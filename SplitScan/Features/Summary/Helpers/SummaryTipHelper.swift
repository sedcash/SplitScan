import Foundation

enum SummaryTipHelper {
    static func clearTip(on receipt: inout Receipt) {
        receipt.tipPolicy = .proportional
        receipt.totals.tip = nil
    }

    static func selectQuickTipPercent(
        _ percent: Int,
        on receipt: inout Receipt
    ) {
        let subtotalMinor = receipt.totals.subtotal.minorUnits
        let tipMinor = Int((Double(subtotalMinor) * Double(percent) / 100.0).rounded())

        receipt.totals.tip = Money(
            minorUnits: max(tipMinor, 0),
            currencyCode: receipt.currencyCode
        )
    }

    static func setOnePersonTipParticipant(
        _ participantID: UUID,
        on receipt: inout Receipt
    ) {
        receipt.tipPolicy = .onePerson(participantID: participantID)
    }

    static func setTipSplitMethod(
        _ method: TipSplitMethodSelection,
        selectedParticipantID: UUID?,
        receipt: inout Receipt
    ) -> UUID? {
        switch method {
        case .proportional:
            receipt.tipPolicy = .proportional
            return nil

        case .equal:
            receipt.tipPolicy = .equal
            return nil

        case .onePerson:
            let fallbackID = selectedParticipantID ?? receipt.participants.first?.id

            if let fallbackID {
                receipt.tipPolicy = .onePerson(participantID: fallbackID)
            }

            return fallbackID
        }
    }

    static func updateCustomTipAmount(
        _ text: String,
        on receipt: inout Receipt
    ) {
        guard let decimal = Decimal(string: text) else {
            receipt.totals.tip = Money(
                minorUnits: 0,
                currencyCode: receipt.currencyCode
            )
            return
        }

        receipt.totals.tip = Money(
            minorUnits: max(decimal.minorUnits, 0),
            currencyCode: receipt.currencyCode
        )
    }
}

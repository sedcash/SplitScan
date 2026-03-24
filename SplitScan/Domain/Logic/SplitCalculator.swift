import Foundation

struct SplitCalculator: SplitCalculating {
        
    func calculate(receipt: Receipt) -> [ParticipantBreakdown] {
        let assignmentsByItem = Dictionary(grouping: receipt.itemAssignments, by: \.itemID)
        let paymentsByParticipant = Dictionary(grouping: receipt.paymentRecords, by: \.participantID)
        let tipPolicy = receipt.tipPolicy

        return receipt.participants.map { participant in
            var lineCharges: [ParticipantLineCharge] = []
            var subtotalMinor = 0

            for item in receipt.items {
                let itemAssignments = assignmentsByItem[item.id, default: []]
                let participantAssignments = itemAssignments.filter { $0.participantID == participant.id }

                guard !participantAssignments.isEmpty else { continue }

                let participantShare = participantAssignments.reduce(0.0) { partial, assignment in
                    partial + assignment.fraction
                }

                guard participantShare > 0 else { continue }

                let itemMinor = Int((Double(item.totalPrice.minorUnits) * participantShare).rounded())
                subtotalMinor += itemMinor

                let suffix: String?
                if participantShare < 1 {
                    let denominator = participantAssignments.first?.denominator ?? 1
                    suffix = "split \(denominator) ways"
                } else {
                    suffix = nil
                }

                lineCharges.append(
                    ParticipantLineCharge(
                        amount: Money(minorUnits: itemMinor, currencyCode: receipt.currencyCode),
                        displaySuffix: suffix,
                        itemID: item.id,
                        itemName: item.name
                    )
                )
            }

            let receiptSubtotalMinor = max(receipt.totals.subtotal.minorUnits, 1)
            let subtotalRatio = Double(subtotalMinor) / Double(receiptSubtotalMinor)

            let taxMinor = Int((Double(receipt.totals.tax?.minorUnits ?? 0) * subtotalRatio).rounded())
            
            let overallTipMinor = receipt.totals.tip?.minorUnits ?? 0
            let tipMinor: Int

            switch tipPolicy {
            case .proportional:
                tipMinor = Int((Double(overallTipMinor) * subtotalRatio).rounded())
            case .equal:
                let participantCount = max(receipt.participants.count, 1)
                tipMinor = Int((Double(overallTipMinor) / Double(participantCount)).rounded())
            case .onePerson(let participantID):
                tipMinor = participant.id == participantID ? overallTipMinor : 0
            }
            
            let serviceFeeMinor = Int((Double(receipt.totals.serviceFee?.minorUnits ?? 0) * subtotalRatio).rounded())

            let totalMinor = subtotalMinor + taxMinor + tipMinor + serviceFeeMinor

            let paymentHistory = (paymentsByParticipant[participant.id] ?? [])
                .sorted { $0.paidAt < $1.paidAt }

            let amountPaidMinor = paymentHistory.reduce(0) { $0 + $1.amount.minorUnits }

            return ParticipantBreakdown(
                amountPaid: Money(minorUnits: amountPaidMinor, currencyCode: receipt.currencyCode),
                itemCount: lineCharges.count,
                lastPayment: paymentHistory.last,
                lines: lineCharges,
                participant: participant,
                totals: ReceiptTotals(
                    grandTotal: Money(minorUnits: totalMinor, currencyCode: receipt.currencyCode),
                    serviceFee: Money.optional(minorUnits: serviceFeeMinor, currencyCode: receipt.currencyCode),
                    subtotal:  Money(minorUnits: subtotalMinor, currencyCode: receipt.currencyCode),
                    tax:  Money.optional(minorUnits: taxMinor, currencyCode: receipt.currencyCode),
                    tip:  Money.optional(minorUnits: tipMinor, currencyCode: receipt.currencyCode)
                )
            )
        }
    }
    
}

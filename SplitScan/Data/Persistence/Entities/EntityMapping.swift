import Foundation

import Foundation

extension ReceiptEntity {
    func toReceipt() -> Receipt {
        Receipt(
            currencyCode: currencyCode,
            date: date,
            id: id,
            imagePath: imagePath,
            items: items
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                .map { $0.toReceiptLineItem(currencyCode: currencyCode) },
            merchantName: merchantName,
            totals: ReceiptTotals(
                grandTotal: totalMinor.map { Money(minorUnits: $0, currencyCode: currencyCode) } ?? .zeroUSD,
                serviceFee: serviceFeeMinor.map { Money(minorUnits: $0, currencyCode: currencyCode) },
                subtotal: subtotalMinor.map { Money(minorUnits: $0, currencyCode: currencyCode) } ?? .zeroUSD,
                tax: taxMinor.map { Money(minorUnits: $0, currencyCode: currencyCode) },
                tip: tipMinor.map { Money(minorUnits: $0, currencyCode: currencyCode) }
            ),
            participants: participants.map { $0.toParticipant() },
            paymentRecords: paymentRecords.map { $0.toModel() },
            itemAssignments: items.flatMap { item in
                item.assignments.compactMap {
                    guard let participantID = $0.participant?.id else { return nil }
                    return $0.toItemAssignment(itemID: item.id, participantID: participantID)
                }
            }
        )
    }
}

extension ReceiptItemEntity {
    
    func toReceiptLineItem(currencyCode: String) -> ReceiptLineItem {
        ReceiptLineItem(
            id: id,
            name: name,
            price: Money(minorUnits: totalMinor / quantity, currencyCode: currencyCode),
            quantity: quantity
        )
    }
    
}

extension ParticipantEntity {
    func toParticipant() -> Participant {
        Participant(
            colorHex: colorHex,
            id: id,
            name: name
        )
    }
}

extension ItemAssignmentEntity {
    
    func toItemAssignment(itemID: UUID, participantID: UUID) -> ItemAssignment {
        ItemAssignment(
            denominator: denominator,
            id: id,
            itemID: itemID,
            numerator: numerator,
            participantID: participantID
        )
    }
    
}

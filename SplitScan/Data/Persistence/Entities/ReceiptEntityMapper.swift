import Foundation

enum ReceiptEntityMapper {
    static func makeReceiptEntity(from receipt: Receipt) -> ReceiptEntity {
        let receiptEntity = ReceiptEntity(
            currencyCode: receipt.currencyCode,
            date: receipt.date,
            id: receipt.id,
            imagePath: receipt.imagePath,
            items: [],
            participants: [],
            paymentRecords: [],
            merchantName: receipt.merchantName,
            serviceFeeMinor: receipt.totals.serviceFee?.minorUnits,
            subtotalMinor: receipt.totals.subtotal.minorUnits,
            taxMinor: receipt.totals.tax?.minorUnits,
            tipMinor: receipt.totals.tip?.minorUnits,
            totalMinor: receipt.totals.grandTotal.minorUnits
        )

        let participantEntities = receipt.participants.map {
            makeParticipantEntity(from: $0)
        }

        let itemEntities = receipt.items.map {
            makeItemEntity(from: $0, receipt: receiptEntity)
        }

        let paymentRecordEntities = receipt.paymentRecords.map {
            makePaymentRecordEntity($0)
        }

        receiptEntity.participants = participantEntities
        receiptEntity.items = itemEntities
        receiptEntity.paymentRecords = paymentRecordEntities

        let participantByID = Dictionary(uniqueKeysWithValues: participantEntities.map { ($0.id, $0) })
        let itemByID = Dictionary(uniqueKeysWithValues: itemEntities.map { ($0.id, $0) })

        for assignment in receipt.itemAssignments {
            guard
                let itemEntity = itemByID[assignment.itemID],
                let participantEntity = participantByID[assignment.participantID]
            else {
                continue
            }

            let assignmentEntity = makeAssignmentEntity(
                from: assignment,
                item: itemEntity,
                participant: participantEntity
            )

            itemEntity.assignments.append(assignmentEntity)
            participantEntity.assignments.append(assignmentEntity)
        }

        return receiptEntity
    }

    static func makeParticipantEntity(from participant: Participant) -> ParticipantEntity {
        ParticipantEntity(
            colorHex: participant.colorHex,
            id: participant.id,
            name: participant.name
        )
    }

    static func makePaymentRecordEntity(_ model: PaymentRecord) -> PaymentRecordEntity {
        PaymentRecordEntity(
            amountMinor: model.amount.minorUnits,
            currencyCode: model.amount.currencyCode,
            id: model.id,
            paidAt: model.paidAt,
            participantID: model.participantID
        )
    }

    static func makeItemEntity(
        from item: ReceiptLineItem,
        receipt: ReceiptEntity? = nil
    ) -> ReceiptItemEntity {
        ReceiptItemEntity(
            id: item.id,
            name: item.name,
            quantity: item.quantity,
            totalMinor: item.totalPrice.minorUnits,
            receipt: receipt
        )
    }

    static func makeAssignmentEntity(
        from assignment: ItemAssignment,
        item: ReceiptItemEntity? = nil,
        participant: ParticipantEntity? = nil
    ) -> ItemAssignmentEntity {
        ItemAssignmentEntity(
            id: assignment.id,
            numerator: assignment.numerator,
            denominator: assignment.denominator,
            item: item,
            participant: participant
        )
    }
}

import Foundation

enum PreviewData {

    static let now = Date()

    // MARK: - Items

    static let pizzaItem = ReceiptLineItem(
        id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
        name: "Margherita Pizza",
        price: Money(minorUnits: 1848),
        quantity: 1
    )

    static let wineItem = ReceiptLineItem(
        id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
        name: "House Wine",
        price: Money(minorUnits: 1200),
        quantity: 1
    )
    
    static let tiramisuItem = ReceiptLineItem(
        id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
        name: "Tiramisu",
        price: Money(minorUnits: 2399),
        quantity: 2
    )

    static let saladItem = ReceiptLineItem(
        id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
        name: "Caesar Salad",
        price: Money(minorUnits: 1099),
        quantity: 1
    )
    
    static let cokeItem = ReceiptLineItem(
        id: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!,
        name: "Caesar Salad",
        price: Money(minorUnits: 199),
        quantity: 1
    )

    // MARK: - Receipt

    static let receipt = Receipt(
        currencyCode: "USD",
        date: now,
        id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
        imagePath: nil,
        items: [pizzaItem, wineItem, saladItem],
        merchantName: "The Olive Garden",
        totals: ReceiptTotals(
            grandTotal: Money(minorUnits: 5279),
            serviceFee: nil,
            subtotal: Money(minorUnits: 4147),
            tax: Money(minorUnits: 332),
            tip: Money(minorUnits: 800)
        ),
        participants: [mike, sarah, you],
        paymentRecords: [
            payment1,
            payment2,
            sarahPayment
        ],
        itemAssignments: itemAssignments
    )
    
    static let receiptEqual = Receipt(
        currencyCode: "USD",
        date: now,
        id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
        imagePath: nil,
        items: [pizzaItem, wineItem, saladItem],
        merchantName: "The Olive Garden",
        totals: ReceiptTotals(
            grandTotal: Money(minorUnits: 5279),
            serviceFee: nil,
            subtotal: Money(minorUnits: 4147),
            tax: Money(minorUnits: 332),
            tip: Money(minorUnits: 800)
        ),
        participants: [mike, sarah, you],
        itemAssignments: equalSplitAssignments
    )

    // MARK: - Participants

    static let mike = Participant(
        colorHex: "#2563EB",
        id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!,
        name: "Mike"
    )

    static let sarah = Participant(
        colorHex: "#DB2777",
        id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!,
        name: "Sarah"
    )

    static let you = Participant(
        colorHex: "#16A34A",
        id: UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!,
        name: "You"
    )

    // MARK: - Assignments

    static let itemAssignments: [ItemAssignment] = [

        ItemAssignment(
            itemID: pizzaItem.id,
            participantID: mike.id
        ),

        ItemAssignment(
            itemID: wineItem.id,
            participantID: sarah.id
        ),

        ItemAssignment(
            itemID: saladItem.id,
            participantID: you.id
        )
    ]
    
    

    // MARK: - Equal Split

    static let equalSplitAssignments: [ItemAssignment] = [

        ItemAssignment(
            denominator: 3,
            itemID: pizzaItem.id,
            numerator: 1,
            participantID: mike.id
        ),

        ItemAssignment(
            denominator: 3,
            itemID: pizzaItem.id,
            numerator: 1,
            participantID: sarah.id,
        ),

        ItemAssignment(
            denominator: 3,
            itemID: pizzaItem.id,
            numerator: 1,
            participantID: you.id
        ),

        ItemAssignment(
            itemID: wineItem.id,
            participantID: sarah.id
        ),

        ItemAssignment(
            itemID: saladItem.id,
            participantID: you.id
        )
    ]
    
        static let caesar = ParticipantLineCharge(
            amount: Money(minorUnits: 1299),
            displaySuffix: nil,
            itemID: saladItem.id,
            itemName: "Caesar Salad",
        )

        static let pizzaSplit = ParticipantLineCharge(
            amount: Money(minorUnits: 849),
            itemID: pizzaItem.id,
            itemName: "Margherita Pizza"
        )

        static let tiramisuSplit = ParticipantLineCharge(
            amount: Money(minorUnits: 300),
            itemID: tiramisuItem.id,
            itemName: "Tiramisu",
        )

        static let cokeSplit = ParticipantLineCharge(
            amount: Money(minorUnits: 117),
            itemID: cokeItem.id,
            itemName: "Coca Cola"
        )


        static let unpaid = ParticipantBreakdown(
            amountPaid: Money(minorUnits: 0),
            itemCount: 3,
            lines: [
                caesar,
                pizzaSplit,
                cokeSplit
            ],
            participant: mike,
            totals: ReceiptTotals(
                grandTotal: Money(minorUnits: 2354),
                serviceFee: nil,
                subtotal: Money(minorUnits: 2149),
                tax: Money(minorUnits: 205),
                tip: nil
            )
        )
    
    
    
    static let partial = ParticipantBreakdown(
            amountPaid: Money(minorUnits: 2000),
            itemCount: 4,
            lines: [
                caesar,
                pizzaSplit,
                tiramisuSplit,
                cokeSplit
            ],
            participant: you,
            totals: ReceiptTotals(
                grandTotal: Money(minorUnits: 2770),
                serviceFee: nil,
                subtotal: Money(minorUnits: 2565),
                tax: Money(minorUnits: 205),
                tip: Money(minorUnits: 1402)
            )
        )
    
    static let paidWithoutHistory = ParticipantBreakdown(
           amountPaid: Money(minorUnits: 5557),
           itemCount: 3,
           lines: [
               caesar,
               pizzaSplit,
               tiramisuSplit
           ],
           participant: sarah,
           totals: ReceiptTotals(
               grandTotal: Money(minorUnits: 5557),
               serviceFee: Money(minorUnits: 502),
               subtotal: Money(minorUnits: 3848),
               tax: Money(minorUnits: 308),
               tip: Money(minorUnits: 1402)
           )
       )
    
    static let paidWithHistory = ParticipantBreakdown(
           amountPaid: Money(minorUnits: 5557),
           itemCount: 3,
           lines: [
               caesar,
               pizzaSplit,
               tiramisuSplit
           ],
           participant: sarah,
           totals: ReceiptTotals(
               grandTotal: Money(minorUnits: 5557),
               serviceFee: Money(minorUnits: 502),
               subtotal: Money(minorUnits: 3848),
               tax: Money(minorUnits: 308),
               tip: Money(minorUnits: 1402)
           )
       )

    // MARK: - Payment History

    static let payment1 = PaymentRecord(
        amount: Money(minorUnits: 2000),
        id: UUID(uuidString: "99999999-AAAA-BBBB-CCCC-DDDDDDDDDDDD")!,
        paidAt: now.addingTimeInterval(-600),
        participantID: you.id
    )

    static let payment2 = PaymentRecord(
        amount: Money(minorUnits: 2638),
        id: UUID(uuidString: "99999999-EEEE-FFFF-CCCC-DDDDDDDDDDDD")!,
        paidAt: now,
        participantID: you.id
    )

    static let sarahPayment = PaymentRecord(
        amount: Money(minorUnits: 1800),
        id: UUID(uuidString: "88888888-AAAA-BBBB-CCCC-DDDDDDDDDDDD")!,
        paidAt: now,
        participantID: sarah.id
    )

    // MARK: - OCR

    static let parsedOCRResult = OCRResult(
        fullText: """
        The Olive Garden
        Margherita Pizza 18.48
        House Wine 12.00
        Caesar Salad 10.99
        Subtotal 41.47
        Tax 3.32
        Tip 8.00
        Total 52.79
        """,
        lines: [
            "The Olive Garden",
            "Margherita Pizza 18.48",
            "House Wine 12.00",
            "Caesar Salad 10.99",
            "Subtotal 41.47",
            "Tax 3.32",
            "Tip 8.00",
            "Total 52.79"
        ]
    )
}

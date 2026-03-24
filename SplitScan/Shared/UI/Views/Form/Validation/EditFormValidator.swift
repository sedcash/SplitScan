import Foundation

enum EditFormValidator {

    static func validate(
        mode: EditSheetMode,
        state: EditFormState
    ) -> [ValidationError] {
        var errors: [ValidationError] = []

        switch mode {
        case .editReceiptInfo:
            if state.merchantName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty {
                errors.append(
                    ValidationError(
                        field: .merchantName,
                        message: "Merchant name is required."
                    )
                )
            }

            let maximumAllowedDate = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: .now
            ) ?? .now

            if state.date > maximumAllowedDate {
                errors.append(
                    ValidationError(
                        field: .dateTime,
                        message: "Date cannot be too far in the future."
                    )
                )
            }

        case .editItem:
            if state.itemName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty {
                errors.append(
                    ValidationError(
                        field: .itemName,
                        message: "Item name is required."
                    )
                )
            }

            guard let price = Decimal(string: state.priceText), price > 0 else {
                errors.append(
                    ValidationError(
                        field: .price,
                        message: "Enter a valid price greater than 0."
                    )
                )
                return errors
            }

        case .addItem:
            if state.itemName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty {
                errors.append(
                    ValidationError(
                        field: .itemName,
                        message: "Item name is required."
                    )
                )
            }

            guard let price = Decimal(string: state.priceText), price > 0 else {
                errors.append(
                    ValidationError(
                        field: .price,
                        message: "Enter a valid price greater than 0."
                    )
                )
                return errors
            }

            guard let quantity = Int(state.quantityText), quantity >= 1 else {
                errors.append(
                    ValidationError(
                        field: .quantity,
                        message: "Quantity must be at least 1."
                    )
                )
                return errors
            }
            
        case .addParticipant:
            if state.name
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty {
                errors.append(
                    ValidationError(
                        field: .name,
                        message: "Name can not be empty"
                    )
                )
            }
        }

        return errors
    }
    
}

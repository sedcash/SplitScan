import SwiftUI

struct EditFormSheetView: View {
    let availableColors: [String]
    let isSaveEnabled: Bool
    let mode: EditSheetMode
    let onCancel: () -> Void
    let validationErrors: [ValidationError]
    let onSave: () -> Void
    @Binding private var state: EditFormState

    init(
        mode: EditSheetMode,
        availableColors: [String] = [],
        isSaveEnabled: Bool,
        validationErrors: [ValidationError],
        state: Binding<EditFormState>,
        onCancel: @escaping () -> Void,
        onSave: @escaping () -> Void
    ) {
        self.mode = mode
        self.availableColors = availableColors
        self.onCancel = onCancel
        self.onSave = onSave
        self.isSaveEnabled = isSaveEnabled
        _state = state
        self.validationErrors = validationErrors
    }
    
    var body: some View {
        NavigationStack {
            ScreenShellView(
                contentBackground: Color(.systemBackground),
                header: {
                    header
                },
                content: {
                    content
                },
                footer: {
                    footer
                }
            )
        }
        .presentationDetents(sheetDetents)
        .presentationDragIndicator(.visible)
    }


    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            formFields
            
            if case .editItem = mode {
                totalPreviewView
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private var header: some View {
        HStack {
            Text(mode.title)
                .font(.title3.weight(.semibold))

            Spacer()

            Button {
                onCancel()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, Spacing.lg)
        .padding(.horizontal)
    }

    private var footer: some View {
        FooterButtonView(
            title: mode.saveButtonTitle,
            isEnabled: isSaveEnabled,
            error: nil,
            action: onSave
        )
    }

    @ViewBuilder
    private var formFields: some View {
        switch mode {
        case .editReceiptInfo:
            merchantNameField
            dateField

        case .editItem:
            itemNameField
            priceField

        case .addItem:
            itemNameField
            priceField
            quantityField
            
        case .addParticipant:
            participantField
            colorField
        }
    }
    
    private var colorField: some View {
        VStack(alignment: .leading) {
            Text("Pick a color")
            FlowLayout {
                ForEach(availableColors, id: \.self) { color in
                    let isSelected = state.color == color
                    Button {
                        state.color = color
                    } label: {
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 30, height: 30)
                            .overlay {
                                Circle()
                                    .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
                                    .padding(1)
                            }
                            .overlay {
                                Circle()
                                    .stroke(
                                        isSelected ? Color.blue : Color.clear,
                                        lineWidth: 2
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var merchantNameField: some View {
        FormFieldSection(title: "Merchant Name") {
            formTextField("Enter merchant name", text: $state.merchantName)
            fieldErrorView(for: .merchantName)
        }
    }

    private var dateField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date & Time")
                .font(.headline)
                .foregroundStyle(.secondary)

            DatePicker(
                "",
                selection: $state.date,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )

            fieldErrorView(for: .dateTime)
        }
    }

    private var itemNameField: some View {
        FormFieldSection(title: "Item Name") {
            formTextField("Enter item name", text: $state.itemName)
            fieldErrorView(for: .itemName)
        }
    }
    
    private var participantField: some View {
        FormFieldSection(title: "Name") {
            formTextField("Enter participant name", text: $state.name)
            fieldErrorView(for: .name)
        }
    }

    private var priceField: some View {
        FormFieldSection(title: "Price (per item)") {
            HStack(spacing: 12) {
                Text("$")
                    .font(.largeTitle.weight(.semibold))
                formTextField("0.00", text: $state.priceText)
            }
            fieldErrorView(for: .price)
        }
    }

    private var quantityField: some View {
        FormFieldSection(title: "Quantity") {
            formTextField("1", text: $state.quantityText)
            fieldErrorView(for: .quantity)
        }
    }

    private var totalPreviewView: some View {
        Group {
            if let price = Decimal(string: state.priceText),
               let quantity = Decimal(string: state.quantityText)
            {
                let total = price * quantity
                Text("Total for \(state.quantityText) items: \(total.formatted())")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func formTextField(
        _ placeholder: String,
        text: Binding<String>
    ) -> some View {
        TextField(placeholder, text: text)
            .textInputAutocapitalization(.words)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
    }

    private func fieldErrorView(for field: EditFormField) -> some View {
        let message = validationErrors.first(where: { $0.field == field })?.message

        return Group {
            if let message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }

    private var sheetDetents: Set<PresentationDetent> {
        switch mode {
        case .editReceiptInfo, .editItem, .addParticipant:
            return [.medium]
        case .addItem:
            return [.large]
        }
    }

    private var itemIDForComparison: UUID {
        switch mode {
        case .editItem(let itemID):
            return itemID
        default:
            return UUID()
        }
    }

}

#Preview {
    EditFormSheetView(
        mode: .editItem(itemID: .init()),
        availableColors: Participant.participantPalette,
        isSaveEnabled: true,
        validationErrors: [],
        state: .constant(EditFormState.addParticipant(name: "You", color: "#2563EB")),
        onCancel: {},
        onSave: {}
    )
}

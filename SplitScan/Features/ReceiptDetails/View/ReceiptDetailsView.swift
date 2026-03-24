import SwiftUI

struct ReceiptDetailsView: View {
    
    @State var viewModel: ReceiptDetailsViewModel
    let presentationStyle: PresentationStyle
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScreenShellView {
            header
        } content: {
            content
        } footer: {
            continueButton
        }
        .navigationTitle("Receipt Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.editReceiptInfoTapped) {
                    Text("Edit")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.black)
                        .padding()
                        .frame(height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.secondarySystemBackground))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(item: sheetBinding) { mode in
            EditFormSheetView(
                mode: mode,
                isSaveEnabled: viewModel.canContinue,
                validationErrors: viewModel.validationErrors,
                state: $viewModel.state,
                onCancel: {
                    viewModel.dismissSheet()
                },
                onSave: {
                    viewModel.saveForm(mode: mode)
                }
            )
        }
        .fullScreenCover(item: modalBinding) { destination in
            switch destination {
            case .camera:
                EmptyView()
                
            case .imagePreview(let path):
                ReceiptImagePreviewView(
                    imagePath: path,
                    onClose: {
                        viewModel.modalDestination = nil
                    },
                    onRetake: {
                        viewModel.retakePhotoTapped()
                    }
                )
            }
        }
    }
    
    private var dismissButton: some View {
        Group {
            switch presentationStyle {
            case .pushed:
                Button {
                    dismiss()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(.headline)
                }

            case .modal:
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color(.secondarySystemBackground))
                        )
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.receipt.merchantName)
                    .font(.title2)

                Text(viewModel.formattedDate)
                    .foregroundStyle(.secondary)
            }

            receiptImageButton
        }
        .padding()
    }

    private var content: some View {
        VStack(spacing: Spacing.lg) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.receipt.items, id: \.id) { item in
                    ReceiptDetailsItemRowView(
                        item: item,
                        onTap: {
                            viewModel.editItemTapped(item)
                        },
                        decrementAction: {
                            viewModel.decrementItemQuantity(itemID: item.id)
                        },
                        incrementAction: {
                            viewModel.incrementItemQuantity(itemID: item.id)
                        }
                    )

                    Divider()
                }

                Button {
                    viewModel.addItemTapped()
                } label: {
                    HStack {
                        Spacer()
                        Label("Add Item", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundStyle(Color.blue)
                        Spacer()
                    }
                    .padding()
                }
                .buttonStyle(.plain)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            )
            
            totalsView
            
            Text("Tap an item to edit its details")
                .font(.system(size: 16, weight: .regular))
        }
        .padding()
    }
    
    private var totalsView: some View {
        let totals = viewModel.receipt.totals

        let rows: [(String, String?)] = [
            ("Subtotal", totals.subtotal.formatted()),
            ("Tax", totals.tax?.formatted()),
            ("Service Fee", totals.serviceFee?.formatted()),
            ("Tip", totals.tip?.formatted())
        ]

        let total = totals.grandTotal.formatted()

        return VStack(spacing: Spacing.sm) {
            ForEach(rows, id: \.0) { title, value in
                if let value {
                    MoneyLabel(title: title, value: value)
                }
            }

            Divider()

            MoneyLabel(title: "Total", value: total)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        )
    }
    
    @ViewBuilder
    private var receiptThumbnail: some View {
        if
            let imagePath = viewModel.receipt.imagePath,
            let uiImage = UIImage(contentsOfFile: imagePath)
        {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.tertiarySystemBackground))
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
        }
    }
    
    private var receiptImageButton: some View {
        Button {
            viewModel.receiptImageButtonTapped()
        } label: {
            HStack(spacing: 12) {
                receiptThumbnail

                Image(systemName: viewModel.receipt.imagePath == nil ? "camera" : "photo")
                    .font(.title3)
                    .foregroundStyle(.primary)

                Text(viewModel.receipt.imagePath == nil ? "Add receipt photo" : "View receipt image")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }

    private var continueButton: some View {
        FooterButtonView(
            title: "Continue to Split",
            trailingSystemImage: "chevron.right",
            isEnabled: viewModel.canContinue,
            action: viewModel.continueTapped
        )
    }
    
    private var sheetBinding: Binding<EditSheetMode?> {
        Binding(
            get: { viewModel.activeSheet },
            set: { viewModel.activeSheet = $0 }
        )
    }
    
    private var modalBinding: Binding<ReceiptDetailsModalDestination?> {
        Binding(
            get: { viewModel.modalDestination },
            set: { viewModel.modalDestination = $0 }
        )
    }
    
}

#Preview("ReceiptDetailsView") {
    NavigationStack {
        ReceiptDetailsView(
            viewModel: PreviewFactory.makeReceiptDetailsViewModel(),
            presentationStyle: .pushed
        )
    }
}

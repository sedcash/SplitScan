import PhotosUI
import SwiftUI

struct ScanReceiptView: View {
    enum Metrics {
        static let cardCornerRadius: CGFloat = 28
        static let cardHorizontalPadding: CGFloat = 24
        static let cardMaxWidth: CGFloat = 560
        static let cardPadding: CGFloat = 24
        static let cardSpacing: CGFloat = 24
        static let closeButtonSize: CGFloat = 56
        static let closeButtonTopTrailingInset: CGFloat = 20
        static let screenPadding: CGFloat = 24
    }

    @State private var isShowingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    @State var viewModel: ScanReceiptViewModel

    init(viewModel: ScanReceiptViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            centeredCard
        }
        .photosPicker(
            isPresented: $isShowingPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .task {
            await viewModel.prepareCamera()
        }
        .task(id: selectedPhotoItem) {
            guard let selectedPhotoItem else { return }
            defer { self.selectedPhotoItem = nil }

            do {
                if
                    let data = try await selectedPhotoItem.loadTransferable(type: Data.self),
                    let image = UIImage(data: data)
                {
                    await viewModel.processPickedImage(image)
                } else {
                    viewModel.errorMessage = "Unable to load selected image."
                }
            } catch {
                viewModel.errorMessage = "Failed to load image from gallery."
            }
        }
        .onDisappear {
            selectedPhotoItem = nil
            isShowingPhotoPicker = false
            viewModel.stopCamera()
        }
    }

    private var centeredCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: Metrics.cardSpacing) {
                VStack(spacing: 8) {
                    Text("Split the Bill")
                        .font(.largeTitle.weight(.semibold))

                    Text("Scan your receipt to get started")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                ReceiptScannerView()

                VStack(spacing: Spacing.md) {
                    PrimaryButton(
                        title: "Capture Receipt",
                        leadingSystemImage: "camera",
                        isEnabled: !viewModel.isPreparingCamera && !viewModel.isProcessingImage
                    ) {
                        Task {
                            await viewModel.capturePhoto()
                        }
                    }

                    PrimaryButton(
                        title: "Upload from Gallery",
                        leadingSystemImage: "square.and.arrow.up",
                        style: .secondary,
                        isEnabled: !viewModel.isProcessingImage
                    ) {
                        isShowingPhotoPicker = true
                    }
                }

                if viewModel.isPreparingCamera {
                    Text("Preparing camera…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if viewModel.isProcessingImage {
                    ProgressView("Processing receipt…")
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Or enter receipt details manually") {
                    // hook up later if you want
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(Metrics.cardPadding)
            .frame(maxWidth: Metrics.cardMaxWidth)
            .background(
                RoundedRectangle(cornerRadius: Metrics.cardCornerRadius)
                    .fill(Color(red: 241 / 255, green: 245 / 255, blue: 252 / 255))
            )
            .padding(Metrics.screenPadding)

            Button(action: viewModel.cancelButtonTapped) {
                Image(systemName: "xmark")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.primary.opacity(0.8))
                    .frame(
                        width: Metrics.closeButtonSize,
                        height: Metrics.closeButtonSize
                    )
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, Metrics.closeButtonTopTrailingInset)
            .padding(.trailing, Metrics.closeButtonTopTrailingInset)
        }
    }
}

#Preview("Scan View") {
    ScanReceiptView(
        viewModel: PreviewFactory.makeScanReceiptViewModel()
    )
}

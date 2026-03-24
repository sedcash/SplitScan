import SwiftUI

struct ReceiptImagePreviewView: View {
    enum Metrics {
        static let closeButtonSize: CGFloat = 44
        static let contentHorizontalPadding: CGFloat = 24
        static let headerTopPadding: CGFloat = 20
        static let retakeHorizontalPadding: CGFloat = 16
        static let retakeVerticalPadding: CGFloat = 10
    }

    let imagePath: String

    let onClose: () -> Void
    let onRetake: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack {
                header
                Spacer()
                image
                Spacer()
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Receipt Image")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            Spacer()

            Button(action: onRetake) {
                Label("Retake", systemImage: "camera")
                    .padding(.horizontal, Metrics.retakeHorizontalPadding)
                    .padding(.vertical, Metrics.retakeVerticalPadding)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .frame(
                        width: Metrics.closeButtonSize,
                        height: Metrics.closeButtonSize
                    )
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.12))
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Metrics.contentHorizontalPadding)
        .padding(.top, Metrics.headerTopPadding)
    }

    private var image: some View {
        Group {
            if let uiImage = UIImage(contentsOfFile: imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, Metrics.contentHorizontalPadding)
            } else {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)

                    Text("Unable to load image")
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
    }
}

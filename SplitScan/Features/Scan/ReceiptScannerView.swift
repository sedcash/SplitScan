import SwiftUI

struct ReceiptScannerView: View {
    enum Metrics {
        static let containerCornerRadius: CGFloat = 24
        static let innerPadding: CGFloat = 18
        static let maxHeight: CGFloat = 540
        static let minHeight: CGFloat = 420
        static let previewBottomPadding: CGFloat = 20
        static let scannerFrameBottomPadding: CGFloat = 52
        static let scannerFrameHorizontalPadding: CGFloat = 14
        static let scannerFrameTopPadding: CGFloat = 28
    }

    var body: some View {
        RoundedRectangle(cornerRadius: Metrics.containerCornerRadius)
            .fill(Color(red: 7 / 255, green: 20 / 255, blue: 48 / 255))
            .frame(maxWidth: .infinity)
            .frame(minHeight: Metrics.minHeight, maxHeight: Metrics.maxHeight)
            .overlay {
                ZStack {
                    previewArea
                    scannerFrame
                    footerLabel
                }
                .padding(Metrics.innerPadding)
            }
    }

    private var previewArea: some View {
        VStack {
            Spacer()

            Image(systemName: "camera")
                .font(.system(size: 72, weight: .regular))
                .foregroundStyle(.gray.opacity(0.9))

            Spacer()
        }
    }

    private var footerLabel: some View {
        VStack {
            Spacer()

            Text("Position receipt within frame")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.bottom, Metrics.previewBottomPadding)
        }
    }

    private var scannerFrame: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white, lineWidth: 2)

                ScannerCorner(position: .topLeft)
                    .position(x: 20, y: 20)

                ScannerCorner(position: .topRight)
                    .position(x: width - 20, y: 20)

                ScannerCorner(position: .bottomLeft)
                    .position(x: 20, y: height - 20)

                ScannerCorner(position: .bottomRight)
                    .position(x: width - 20, y: height - 20)
            }
        }
        .padding(.horizontal, Metrics.scannerFrameHorizontalPadding)
        .padding(.top, Metrics.scannerFrameTopPadding)
        .padding(.bottom, Metrics.scannerFrameBottomPadding)
    }
}

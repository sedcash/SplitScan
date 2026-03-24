import SwiftUI

struct ScannerCorner: View {
    enum Metrics {
        static let length: CGFloat = 26
        static let lineWidth: CGFloat = 5
    }

    enum Position {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    let position: Position

    var body: some View {
        Path { path in
            switch position {
            case .topLeft:
                path.move(to: CGPoint(x: Metrics.length, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: Metrics.length))

            case .topRight:
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: Metrics.length, y: 0))
                path.addLine(to: CGPoint(x: Metrics.length, y: Metrics.length))

            case .bottomLeft:
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: Metrics.length))
                path.addLine(to: CGPoint(x: Metrics.length, y: Metrics.length))

            case .bottomRight:
                path.move(to: CGPoint(x: 0, y: Metrics.length))
                path.addLine(to: CGPoint(x: Metrics.length, y: Metrics.length))
                path.addLine(to: CGPoint(x: Metrics.length, y: 0))
            }
        }
        .stroke(
            Color.green,
            style: StrokeStyle(
                lineWidth: Metrics.lineWidth,
                lineCap: .square
            )
        )
        .frame(width: Metrics.length, height: Metrics.length)
    }
}

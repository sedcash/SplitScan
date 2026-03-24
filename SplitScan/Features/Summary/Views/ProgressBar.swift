import SwiftUI

struct ProgressBar: View {
    enum Metrics {
        static let height: CGFloat = 10
        static let trackOpacity: Double = 0.2
    }

    let progress: Double
    let color: Color

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(Metrics.trackOpacity))

                Capsule()
                    .fill(color)
                    .frame(width: geometry.size.width * clampedProgress)
            }
        }
        .frame(height: Metrics.height)
    }
}

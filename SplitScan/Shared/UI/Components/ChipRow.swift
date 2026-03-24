import SwiftUI

struct PaymentStatusView: View {
    enum Metrics {
        static let cornerRadius: CGFloat = 8
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 6
    }

    let text: String
    let textColor: Color

    var backgroundColor: Color {
        textColor.opacity(0.12)
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(textColor)
            .padding(.horizontal, Metrics.horizontalPadding)
            .padding(.vertical, Metrics.verticalPadding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
    }
}

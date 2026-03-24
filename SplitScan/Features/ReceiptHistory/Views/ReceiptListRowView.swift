import SwiftUI

struct ReceiptListRowView: View {
    enum Metrics {
        static let cornerRadius: CGFloat = 16
        static let imageCornerRadius: CGFloat = 12
        static let imageSize: CGFloat = 60
        static let rowPadding: CGFloat = 16
        static let shadowOpacity: Double = 0.05
        static let shadowRadius: CGFloat = 8
        static let shadowYOffset: CGFloat = 3
    }

    let row: ReceiptListRowModel

    var body: some View {
        HStack(spacing: Spacing.md) {
            thumbnail

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(row.merchantName)
                    .font(.headline)

                MoneyLabel(
                    title: row.date.displayDate,
                    value: row.total.formatted(),
                    valueFont: .title3.weight(.semibold),
                    valueColor: .blue
                )

                PaymentStatusView(
                    text: row.paidStatusText,
                    textColor: row.paymentStatus.color
                )
            }
        }
        .padding(Metrics.rowPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(Metrics.shadowOpacity),
                    radius: Metrics.shadowRadius,
                    y: Metrics.shadowYOffset
                )
        )
    }

    private var thumbnail: some View {
        Group {
            if
                let imagePath = row.imagePath,
                let uiImage = UIImage(contentsOfFile: imagePath)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
                    .padding(12)
            }
        }
        .frame(width: Metrics.imageSize, height: Metrics.imageSize)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Metrics.imageCornerRadius))
    }
}

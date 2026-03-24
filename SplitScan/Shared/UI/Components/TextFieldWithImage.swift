import SwiftUI

struct TextFieldWithImage: View {
    enum Metrics {
        static let cornerRadius: CGFloat = 16
        static let iconSize: CGFloat = 24
        static let spacing: CGFloat = 12
    }

    let imageName: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: Metrics.spacing) {
            Image(systemName: imageName)
                .foregroundStyle(.gray)
                .frame(width: Metrics.iconSize, height: Metrics.iconSize)

            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .font(.title2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

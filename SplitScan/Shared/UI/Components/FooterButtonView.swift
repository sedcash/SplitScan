import SwiftUI

struct FooterButtonView: View {
    
    let action: () -> Void
    let error: String?
    let isEnabled: Bool
    let leadingSystemImage: String?
    let style: PrimaryButton.Style
    let title: String
    let trailingSystemImage: String?
    
    init(
        title: String,
        leadingSystemImage: String? = nil,
        trailingSystemImage: String? = nil,
        style: PrimaryButton.Style = .primary,
        isEnabled: Bool,
        error: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.leadingSystemImage = leadingSystemImage
        self.trailingSystemImage = trailingSystemImage
        self.style = style
        self.isEnabled = isEnabled
        self.error = error
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            PrimaryButton(
                title: title,
                leadingSystemImage: leadingSystemImage,
                trailingSystemImage: trailingSystemImage,
                style: style,
                width: .fill,
                isEnabled: isEnabled,
                action: action
            )
            
            if !isEnabled, let error {
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }
        }
    }
}

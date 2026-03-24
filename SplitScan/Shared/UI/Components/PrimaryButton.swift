
import SwiftUI

struct PrimaryButton: View {
    
    enum Style {
        case primary
        case secondary
    }
    
    enum Width {
        case fill
        case fit
    }
    
    let action: () -> Void
    let isEnabled: Bool
    let leadingSystemImage: String?
    let style: Style
    let title: String
    let trailingSystemImage: String?
    let width: Width
    
    init(
        title: String,
        leadingSystemImage: String? = nil,
        trailingSystemImage: String? = nil,
        style: Style = .primary,
        width: Width = .fill,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.leadingSystemImage = leadingSystemImage
        self.trailingSystemImage = trailingSystemImage
        self.style = style
        self.width = width
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if let leadingSystemImage {
                    Image(systemName: leadingSystemImage)
                }
                
                Text(title)
                    .font(.headline)
                
                if let trailingSystemImage {
                    Image(systemName: trailingSystemImage)
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: width == .fill ? .infinity : nil)
            .frame(height: 52)
            .padding(.horizontal, width == .fit ? 16 : 0)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.sm))
            .overlay(borderOverlay)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.blue.opacity(isEnabled ? 1 : 0.40)
        case .secondary:
            return Color(.secondarySystemBackground).opacity(isEnabled ? 1 : 0.60)
        }
    }
    
    @ViewBuilder
    private var borderOverlay: some View {
        switch style {
        case .primary:
            EmptyView()
        case .secondary:
            RoundedRectangle(cornerRadius: Spacing.sm)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        }
    }
}

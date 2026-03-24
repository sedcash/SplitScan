import SwiftUI

struct CardStyleModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var backgroundColor: Color = Color(.systemBackground)
    var shadowColor: Color = .black.opacity(0.08)
    var shadowRadius: CGFloat = 8
    var shadowY: CGFloat = 4

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
    }
}

extension View {
    func cardStyle(
        cornerRadius: CGFloat = 8
    ) -> some View {
        self.modifier(CardStyleModifier(cornerRadius: cornerRadius))
    }
}

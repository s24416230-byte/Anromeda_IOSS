import SwiftUI

/// Dopamine-style card: pure blur, no outline.
struct DopamineCard: ViewModifier {
    var cornerRadius: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    func dopeCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(DopamineCard(cornerRadius: cornerRadius))
    }
}
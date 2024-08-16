import SwiftUI

struct GradientButtonBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.background(LinearGradient(gradient: Gradient(colors: [
            Color(hex: "#A0398A"),
            Color(hex: "#E23146"),
            Color(hex: "#FF3E47")
        ]),
                                          startPoint: .leading,
                                          endPoint: .trailing))
    }
}

extension View {
    func makeGradientButtonBackground() -> some View {
        self.modifier(GradientButtonBackground())
    }
}

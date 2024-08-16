import SwiftUI

struct ViewGradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.background(LinearGradient(gradient: Gradient(colors: [
            Color(hex: "#31333E"),
            Color(hex: "#000000")
        ]),
                                          startPoint: .top,
                                          endPoint: .bottom))
    }
}

extension View {
    func makeViewGradientBackground() -> some View {
        self.modifier(ViewGradientBackground())
    }
}

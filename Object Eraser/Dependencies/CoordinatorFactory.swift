import SwiftUI
import SwiftUICoordinator

@MainActor
protocol CoordinatorFactory {
    func makeMainCoordinator(parent: Coordinator) -> MainCoordinator
    func makeWelcomeCoordinator(parent: Coordinator) -> WelcomeCoordinator
}

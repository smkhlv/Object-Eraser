import SwiftUI
import SwiftUICoordinator

@MainActor
final class DependencyContainer {
    
    let factory = NavigationControllerFactory()
    lazy var delegate = factory.makeNavigationDelegate([])
    lazy var navigationController = factory.makeNavigationController(delegate: delegate)
    
    //let deepLinkHandler = DeepLinkHandler.shared
    
    private(set) var appCoordinator: AppCoordinator?
    
    func set(_ coordinator: AppCoordinator) {
        guard appCoordinator == nil else {
            return
        }
        
        self.appCoordinator = coordinator
    }
}

extension DependencyContainer: CoordinatorFactory {
    func makeAppCoordinator(window: UIWindow) -> AppCoordinator {
        return AppCoordinator(
            window: window,
            navigationController: navigationController
        )
    }
    
    func makeMainCoordinator(parent: Coordinator) -> MainCoordinator {
        return MainCoordinator(
            parent: parent,
            navigationController: navigationController,
            factory: self
        )
    }
    
    func makeWelcomeCoordinator(parent: Coordinator) -> WelcomeCoordinator {
        return WelcomeCoordinator(
            parent: parent,
            navigationController: navigationController,
            factory: self
        )
    }
}

extension DependencyContainer {
    static let mock = DependencyContainer()
    
    static let mockMainCoordinator = MainCoordinator(
        parent: nil,
        navigationController: NavigationControllerFactory().makeNavigationController(),
        factory: DependencyContainer.mock
    )
    
    static let mockWelcomeCoordinator = WelcomeCoordinator(
        parent: nil,
        navigationController: NavigationControllerFactory().makeNavigationController(),
        factory: DependencyContainer.mock
    )
}

import SwiftUI
import SwiftUICoordinator

class WelcomeCoordinator: Routing {

    // MARK: - Internal properties
    
    weak var parent: Coordinator?
    var childCoordinators = [WeakCoordinator]()
    let navigationController: NavigationController
    let startRoute: WelcomeRoute
    let factory: CoordinatorFactory

    // MARK: - Initialization

    init(
        parent: Coordinator?,
        navigationController: NavigationController,
        startRoute: WelcomeRoute = .welcome,
        factory: CoordinatorFactory
    ) {
        self.parent = parent
        self.navigationController = navigationController
        self.startRoute = startRoute
        self.factory = factory
    }
    
    func handle(_ action: CoordinatorAction) {
        switch action {
        case WelcomeAction.toWelcome:
            let coordinator = factory.makeWelcomeCoordinator(parent: self)
            try? coordinator.start()
        case WelcomeAction.toPaywall:
            let coordinator = factory.makeWelcomeCoordinator(parent: self)
            try? coordinator.show(route: .paywall)
        case WelcomeAction.toPhotoPicker:
            let coordinator = factory.makeMainCoordinator(parent: self)
            coordinator.set(routes: [.photoPicker])
        default:
            parent?.handle(action)
        }
    }
    
    func handle(_ deepLink: DeepLink, with params: [String: String]) { }
}

// MARK: - RouterViewFactory

extension WelcomeCoordinator: RouterViewFactory {
    
    @ViewBuilder
    public func view(for route: WelcomeRoute) -> some View {
        switch route {
        case .welcome:
            WelcomeView<WelcomeCoordinator>()
            //EmptyView()
        case .paywall:
            PayWall<WelcomeCoordinator>()
            //EmptyView()
        case .photoPicker:
            PhotoPicker<WelcomeCoordinator>()
        }
    }
}


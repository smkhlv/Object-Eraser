import SwiftUI
import SwiftUICoordinator

class MainCoordinator: Routing {

    // MARK: - Internal properties
    
    weak var parent: Coordinator?
    var childCoordinators = [WeakCoordinator]()
    let navigationController: NavigationController
    let startRoute: MainRoute
    let factory: CoordinatorFactory

    // MARK: - Initialization

    init(
        parent: Coordinator?,
        navigationController: NavigationController,
        startRoute: MainRoute = .photoPicker,
        factory: CoordinatorFactory
    ) {
        self.parent = parent
        self.navigationController = navigationController
        self.startRoute = startRoute
        self.factory = factory
    }
    
    func handle(_ action: CoordinatorAction) {
        switch action {
        case MainAction.toPhotoPicker:
            let coordinator = factory.makeMainCoordinator(parent: self)
            try? coordinator.start()
        case MainAction.toPhotoEditor(let route):
            if case let .photoEditor(asset) = route as? MainRoute {
                let coordinator = factory.makeMainCoordinator(parent: self)
                try? coordinator.show(route: .photoEditor(asset))
            }
        default:
            parent?.handle(action)
        }
    }
    
    func handle(_ deepLink: DeepLink, with params: [String: String]) { }
}

// MARK: - RouterViewFactory

extension MainCoordinator: RouterViewFactory {
    
    @ViewBuilder
    public func view(for route: MainRoute) -> some View {
        switch route {
        case .photoPicker:
            PhotoPicker<MainCoordinator>()
        case .paywall:
            PayWall<MainCoordinator>()
        case .photoEditor(let asset):
            PhotoEditor<MainCoordinator>(asset: asset)
        }
    }
}


import SwiftUICoordinator

final class AppCoordinator: RootCoordinator {

    func start(with coordinator: any Routing) {
        self.add(child: coordinator)
        try? coordinator.start()
    }
    
    override func handle(_ action: CoordinatorAction) {
        fatalError("Unhadled coordinator action.")
    }
}

extension AppCoordinator: CoordinatorDeepLinkHandling {
    func handle(_ deepLink: DeepLink, with params: [String: String]) { }
}

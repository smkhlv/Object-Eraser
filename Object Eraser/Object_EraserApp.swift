import SwiftUI
import SwiftUICoordinator

@main
struct Object_EraserApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            
        }
    }
    
    init() {
        for family in UIFont.familyNames {
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   - \(name)")
            }
        }
    }
}

final class SceneDelegate: NSObject, UIWindowSceneDelegate {

    var dependencyContainer = DependencyContainer()
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let window = (scene as? UIWindowScene)?.windows.first else {
            return
        }
        
        let appCoordinator = dependencyContainer.makeAppCoordinator(window: window)
        dependencyContainer.set(appCoordinator)
        
        let coordinator = dependencyContainer.makeWelcomeCoordinator(parent: appCoordinator)
        appCoordinator.start(with: coordinator)
        
        _ = ModelDependency()
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}

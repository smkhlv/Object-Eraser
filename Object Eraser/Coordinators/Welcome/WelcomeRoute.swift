import SwiftUICoordinator

enum WelcomeRoute: NavigationRoute {
    case welcome
    case paywall
    case photoPicker

    var title: String? {
        switch self {
        case .welcome:
            return "Magically"
        case .paywall:
            return "Paywall"
        case .photoPicker:
            return "Photo Picker"
        }
    }

    var action: TransitionAction? {
        switch self {
        case .welcome:
            return .push(animated: true)
        case .paywall:
            return .push(animated: true)
//            return .present(animated: true,
//                            modalPresentationStyle: .fullScreen,
//                            delegate: nil,
//                            completion: nil)
        case .photoPicker:
            return .push(animated: true)
        }
    }
}

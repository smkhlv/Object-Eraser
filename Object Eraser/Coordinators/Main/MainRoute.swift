import SwiftUICoordinator
import Photos
import SwiftUI

enum MainRoute: NavigationRoute {
    case photoPicker
    case paywall
    case photoEditor(PHAsset)

    var title: String? {
        switch self {
        case .photoEditor:
            return "  "
        case .paywall:
            return "Paywall"
        case .photoPicker:
            return ""//"Chose photo"
        }
    }

    var action: TransitionAction? {
        switch self {
        case .photoPicker:
            return .push(animated: true)
        case .paywall:
            return .present(animated: true,
                            modalPresentationStyle: .fullScreen,
                            delegate: nil,
                            completion: nil)
        case .photoEditor:
            return .push(animated: true)
        }
    }
}

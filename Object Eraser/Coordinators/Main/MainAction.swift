import SwiftUICoordinator

enum MainAction: CoordinatorAction {
    case toPhotoPicker
    case toPaywall
    case closePayWall
    case toPhotoEditor(NavigationRoute)
}

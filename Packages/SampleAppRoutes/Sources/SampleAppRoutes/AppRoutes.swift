import AuthReluxInt
import NotesUIAPI
import NotesModels
import NavigationReluxInt
import NavigationReluxImpl
import Relux
import ReluxRouter

/// App-specific navigation graph for the relux-sample host.
public enum AppRoute: Relux.Navigation.PathComponent, Sendable, Hashable {
    case splash
    case main
    case account
    case auth(Auth.UI.Model.Page = .logoutFlow)
    case notes(Notes.UI.Model.Page = .list)
}

/// App-specific modal pages.
public enum AppModal: Relux.Navigation.ModalComponent, Sendable, Hashable {
    case debug
}

/// Concrete router type used by the host app.
public typealias AppRouter = Relux.Navigation.ProjectingRouter<AppRoute>

/// Concrete navigation actions injected into SwiftUI environment.
public typealias AppNavigation = NavigationActions<AppRoute, AppModal>

/// Convenience alias for the generic Navigation module.
public typealias AppNavigationModule = Navigation.Module<AppRoute, AppModal>

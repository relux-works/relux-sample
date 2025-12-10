import Relux
import ReluxRouter
import NavigationReluxInt
import AuthReluxInt
import NotesReluxInt
import NotesUIAPI

/// Internal page structure used by ProjectingRouter.
/// Not exposed publicly — external code uses Destination enum.
public enum InternalPage: Relux.Navigation.PathComponent {
    case splash
    case auth(page: Auth.UI.Model.Page)
    case app(page: AppPage)

    public enum AppPage: Relux.Navigation.PathComponent {
        case main
        case account
        case notes(Notes.UI.Model.Page)
    }
}

/// TypeAlias for the concrete Router type.
public typealias AppRouter = Relux.Navigation.ProjectingRouter<InternalPage>

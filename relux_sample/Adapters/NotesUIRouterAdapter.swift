import NotesUIAPI
import NotesReluxInt
import Relux
import NavigationReluxImpl

struct NotesUIRouterAdapter: NotesUIRouting {
    func push(_ page: Notes.UI.Model.Page) -> any Relux.Action {
        AppRouter.Action.push(.app(page: .notes(page)))
    }

    func set(_ page: Notes.UI.Model.Page) -> any Relux.Action {
        AppRouter.Action.set([.app(page: .notes(page))])
    }

    func pop() -> any Relux.Action {
        AppRouter.Action.removeLast()
    }
}

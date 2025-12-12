import NotesReluxInt
import NotesUIAPI
import Relux
import SampleAppRoutes

struct NotesRouterAdapter: Notes.Business.IRouter {
    func pushList() -> any Relux.Action {
        AppRouter.Action.push(.notes(.list))
    }

    func pushCreate() -> any Relux.Action {
        AppRouter.Action.push(.notes(.create))
    }

    func pushDetails(id: Notes.Business.Model.Note.Id) -> any Relux.Action {
        AppRouter.Action.push(.notes(.details(id: id)))
    }

    func pushEdit(note: Notes.Business.Model.Note) -> any Relux.Action {
        AppRouter.Action.push(.notes(.edit(note: note)))
    }

    func back() -> any Relux.Action {
        AppRouter.Action.removeLast()
    }
}


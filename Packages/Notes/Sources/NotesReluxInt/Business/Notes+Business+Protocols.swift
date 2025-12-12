import NotesModels
import Relux

extension Notes.Business {
    public protocol IState: Relux.BusinessState {}
}

extension Notes.Business {
    public protocol IFlow: Relux.Flow {}
}

extension Notes.Business {
    /// Notes-local navigation interface.
    /// Implemented by the host app to map Notes UI intents to app routes.
    public protocol IRouter: Relux.ActionProviding, Sendable {
        func pushList() -> any Relux.Action
        func pushCreate() -> any Relux.Action
        func pushDetails(id: Notes.Business.Model.Note.Id) -> any Relux.Action
        func pushEdit(note: Notes.Business.Model.Note) -> any Relux.Action
        func back() -> any Relux.Action
    }
}

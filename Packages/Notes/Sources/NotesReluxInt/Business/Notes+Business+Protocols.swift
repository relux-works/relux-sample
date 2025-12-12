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

extension Notes.Business {
    /// Type-erased, ActionRelay-friendly router actions.
    /// NotesUI depends on this concrete type instead of a protocol existential.
    public struct RouterActions: Relux.ActionProviding {
        public let pushList: @Sendable () -> any Relux.Action
        public let pushCreate: @Sendable () -> any Relux.Action
        public let pushDetails: @Sendable (id: Notes.Business.Model.Note.Id) -> any Relux.Action
        public let pushEdit: @Sendable (note: Notes.Business.Model.Note) -> any Relux.Action
        public let back: @Sendable () -> any Relux.Action

        public init(router: any Notes.Business.IRouter) {
            self.pushList = { router.pushList() }
            self.pushCreate = { router.pushCreate() }
            self.pushDetails = { id in router.pushDetails(id: id) }
            self.pushEdit = { note in router.pushEdit(note: note) }
            self.back = { router.back() }
        }
    }
}

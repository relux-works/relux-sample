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
        private let pushListAction: @Sendable () -> any Relux.Action
        private let pushCreateAction: @Sendable () -> any Relux.Action
        private let pushDetailsAction: @Sendable (Notes.Business.Model.Note.Id) -> any Relux.Action
        private let pushEditAction: @Sendable (Notes.Business.Model.Note) -> any Relux.Action
        private let backAction: @Sendable () -> any Relux.Action

        public init(router: any Notes.Business.IRouter) {
            self.pushListAction = { router.pushList() }
            self.pushCreateAction = { router.pushCreate() }
            self.pushDetailsAction = { id in router.pushDetails(id: id) }
            self.pushEditAction = { note in router.pushEdit(note: note) }
            self.backAction = { router.back() }
        }

        public func pushList() -> any Relux.Action {
            pushListAction()
        }

        public func pushCreate() -> any Relux.Action {
            pushCreateAction()
        }

        public func pushDetails(id: Notes.Business.Model.Note.Id) -> any Relux.Action {
            pushDetailsAction(id)
        }

        public func pushEdit(note: Notes.Business.Model.Note) -> any Relux.Action {
            pushEditAction(note)
        }

        public func back() -> any Relux.Action {
            backAction()
        }
    }
}

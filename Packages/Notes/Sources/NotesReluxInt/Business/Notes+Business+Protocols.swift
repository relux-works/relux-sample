import NotesModels
import Relux

extension Notes.Business {
    public protocol IState: Relux.BusinessState {}
}

extension Notes.Business {
    public protocol IFlow: Relux.Flow {}
}

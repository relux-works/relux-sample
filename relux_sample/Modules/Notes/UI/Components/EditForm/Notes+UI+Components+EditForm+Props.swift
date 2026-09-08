import SwiftUI

extension Notes.UI.Component.EditForm {
    struct Props: Relux.UI.ViewProps {
        let title: String
        let note: Notes.Business.Model.Note?
        var errorMessage: String? = nil
    }

    struct Actions: Relux.UI.ViewCallbacks {
        let onSave: ViewInputCallback<Notes.Business.Model.Note>
        let onCancel: ViewCallback<Void>
    }
}

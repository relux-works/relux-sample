import SwiftUI

extension Notes.UI.Edit.Container {
    struct Page: Relux.UI.View {
        typealias Note = Notes.Business.Model.Note
        let props: Props
        let actions: Actions

        var body: some View {
            Notes.UI.Component.EditForm(
                props: .init(title: "Edit Note", note: props.note,
                             errorMessage: props.errorMessage),
                actions: .init(onSave: actions.onSave, onCancel: actions.onCancel)
            )
        }
    }
}

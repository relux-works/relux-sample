import SwiftUI

extension Notes.UI.Create.Container {
    struct Page: Relux.UI.View {
        typealias Note = Notes.Business.Model.Note
        let props: Props
        let actions: Actions

        var body: some View {
            Notes.UI.Component.EditForm(
                props: .init(title: "New Note", note: nil,
                             errorMessage: props.errorMessage),
                actions: .init(onSave: actions.onCreate, onCancel: actions.onCancel)
            )
        }
    }
}

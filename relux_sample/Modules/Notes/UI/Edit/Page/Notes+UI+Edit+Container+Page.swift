import SwiftUI

extension Notes.UI.Edit.Container {
    struct Page: View {
        typealias Note = Notes.Business.Model.Note

        @StateObject private var ls: LocalState

        private let props: Props
        private let actions: Actions

        init(
            props: Props,
            actions: Actions
        ) {
            self.props = props
            self.actions = actions
            self._ls = .init(wrappedValue: .init(props: props))
        }

        var body: some View {
            content
                .navigationBarItems(trailing: removeBtn)
                .navBar(middle: createBtn, edge: .bottom)
        }
    }
}

// header
extension Notes.UI.Edit.Container.Page {
    private var removeBtn: some View {
        NavBar.iconBtn(
            systemName: "trash",
            action: actions.onRemove
        )
    }
}

// subviews
extension Notes.UI.Edit.Container.Page {
    private var createBtn: some View {
        AsyncButton(action: onSave) {
            Text("Save")
        }
        .buttonStyle(.borderedProminent)
        .disabled(ls.valid.not)
    }

    private var content: some View {
        form
    }

    private var form: some View {
        Notes.UI.Component.EditForm(
            props: .init(
                title: "Edit note",
                note: $ls.note
            ),
            actions: .init()
        )
    }
}

// reactions
extension Notes.UI.Edit.Container.Page {
    private func onSave() async {
        await actions.onSave(ls.note.asNote(withId: props.note.id))
    }
}

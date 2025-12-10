import SwiftUI

extension Notes.UI.Create.Container {

    struct Page: Relux.UI.View {
        typealias Note = Notes.Business.Model.Note
        
        @StateObject private var ls: LocalState = .init()

        let props: Props
        let actions: Actions

        var body: some View {
            content
                .navBar(middle: createBtn, edge: .bottom)
        }

        private var content: some View {
            form
        }
    }
}


// subviews
extension Notes.UI.Create.Container.Page {
    private var createBtn: some View {
        AsyncButton(action: onCreate) {
            Text("Create")
        }
        .buttonStyle(.borderedProminent)
        .disabled(ls.valid.not)
    }

    private var horizontalExtender: some View {
        HStack { Spacer() }
    }

    private var form: some View {
        Notes.UI.Component.EditForm(
            props: Notes.UI.Component.EditForm.Props(
                title: "New Note",
                note: $ls.note
            ),
            actions: Notes.UI.Component.EditForm.Actions()
        )
    }
}

// reactions
extension Notes.UI.Create.Container.Page {
    private func onCreate() async {
        guard ls.valid else { return }
        await actions.onCreate(ls.note.asNote)
    }
}

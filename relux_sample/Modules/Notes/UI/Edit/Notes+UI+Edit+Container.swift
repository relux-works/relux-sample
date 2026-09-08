import SwiftUI

extension Notes.UI.Edit.Container {
    struct Props: Relux.UI.ViewProps { let note: Notes.Business.Model.Note }
}

extension Notes.UI.Edit {
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note
        let props: Props
        @Environment(\.dismiss) private var dismiss
        @State private var errorMessage: String?

        var body: some View {
            Page(props: .init(note: props.note, errorMessage: errorMessage),
                 actions: .init(onSave: ViewInputCallback(upsert), onCancel: ViewCallback(close)))
        }

        private func upsert(_ note: Note) async {
            switch await actions(actions: { Notes.Business.Effect.upsert(note: note) }) {
            case .success: dismiss()
            case .failure: errorMessage = "Couldn’t save changes. Your draft is safe. Try again."
            }
        }

        private func close() async { dismiss() }
    }
}

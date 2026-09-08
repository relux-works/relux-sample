import SwiftUI

extension Notes.UI.Edit.Container {
    struct Props: Relux.UI.ViewProps { let id: Notes.Business.Model.Note.Id }
}

extension Notes.UI.Edit {
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note
        @EnvironmentObject private var notesState: Notes.UI.State
        @Environment(\.scenePhase) private var scenePhase
        let props: Props
        @Environment(\.dismiss) private var dismiss
        @State private var errorMessage: String?

        var body: some View {
            Group {
                if let note = notesState.note(by: props.id).value.flatMap({ $0 })?.editableNote {
                    Page(props: .init(note: note, errorMessage: errorMessage),
                         actions: .init(onSave: ViewInputCallback(upsert), onCancel: ViewCallback(close)))
                } else {
                    ContentUnavailableView("Note Locked or Unavailable", systemImage: "lock")
                }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background { dismiss() }
            }
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

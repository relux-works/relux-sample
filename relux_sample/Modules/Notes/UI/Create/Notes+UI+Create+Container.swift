import SwiftUI

extension Notes.UI.Create {
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note
        @Environment(\.dismiss) private var dismiss
        @State private var errorMessage: String?

        var body: some View {
            Page(props: .init(errorMessage: errorMessage),
                 actions: .init(onCreate: ViewInputCallback(create), onCancel: ViewCallback(close)))
        }

        private func create(_ note: Note) async {
            // The flow awaits service -> reducer -> UI projection before reporting its outcome.
            switch await actions(actions: { Notes.Business.Effect.upsert(note: note) }) {
            case .success: dismiss()
            case .failure: errorMessage = "Couldn’t save this note. Your draft is safe. Try again."
            }
        }

        private func close() async { dismiss() }
    }
}

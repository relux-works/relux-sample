import SwiftUI

extension Notes.UI.Create {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note
        
        // In SwiftUI-Relux, the Relux resolver injects all UI states into the root view.
        // If a state conforms to ObservableObject, it’s accessible via @EnvironmentObject.
        // If it’s declared using the @Observable macro, it’s available via @Environment.
        @EnvironmentObject private var notesState: Notes.UI.State

        var body: some View {
            content
        }

        private var content: some View {
            Page(
                props: .init(),
                actions: .init(
                    onCreate: { await create($0) }
                )
            )
        }
    }
}

// reactions
extension Notes.UI.Create.Container {
    private func create(_ note: Note) async {
        await actions {
            Notes.Business.Effect.upsert(note: note)
            AppRouter.Action.removeLast()
        }
    }
}

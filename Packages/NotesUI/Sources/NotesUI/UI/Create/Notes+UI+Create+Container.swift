import SwiftUI
import SwiftUIRelux
import NotesReluxInt
import NavigationReluxInt
import SampleAppRoutes

extension Notes.UI.Create {
    struct Container: Relux.UI.Container {
        typealias Note = Notes.Business.Model.Note

        @EnvironmentObject private var notesState: Notes.UI.State
        @EnvironmentObject private var nav: Relux.UI.ActionRelay<AppNavigation>

        var body: some View {
            content
        }

        private var content: some View {
            Page(
                props: .init(),
                actions: .init(
                    onCreate: ViewInputCallback(create)
                )
            )
        }
    }
}

extension Notes.UI.Create.Container {
    private func create(_ note: Note) async {
        switch await actions(actions: { Notes.Business.Effect.upsert(note: note) }) {
        case .success: await close()
        case .failure: break
        }
    }

    private func close() async {
        await action {
            nav.actions.back()
        }
    }
}

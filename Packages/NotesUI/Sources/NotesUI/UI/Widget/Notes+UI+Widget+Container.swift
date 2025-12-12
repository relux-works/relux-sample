import SwiftUI
import NotesReluxInt
import NotesReluxImpl
import NotesUIAPI
import SwiftUIRelux

public extension Notes.UI.Widget {
    struct Container: Relux.UI.Container {
        @EnvironmentObject private var notesState: Notes.UI.State
        @EnvironmentObject private var router: Relux.UI.ActionRelay<any Notes.Business.IRouter>

        public init() {}

        public var body: some View {
            content
                .task { loadData() }
        }

        private var content: some View {
            Page(
                props: .init(
                    notes: notesState.notesGroupedByDay
                ),
                actions: .init(
                    onOpenList: ViewCallback(openList)
                )
            )
        }
    }
}

extension Notes.UI.Widget.Container {
    private func loadData() {
        if notesState.notesGroupedByDay.value.isNil {
            performAsync(delay: 0.5) {
                Notes.Business.Effect.obtainNotes
            }
        }
    }

    private func openList() async {
        await actions { router.actions.pushList() }
    }
}

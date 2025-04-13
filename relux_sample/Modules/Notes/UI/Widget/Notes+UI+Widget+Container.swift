import SwiftUI

extension Notes.UI.Widget {
    struct Container: Relux.UI.Container {
        @EnvironmentObject private var notesState: Notes.UI.State

        var body: some View {
            content
                .task { loadData() }
        }

        private var content: some View {
            Page(
                props: .init(
                    notes: notesState.notesGroupedByDay
                ),
                actions: .init()
            )
        }
    }
}

// reactions
extension Notes.UI.Widget.Container {
    private func loadData() {
        if notesState.notesGroupedByDay.value.isNil {
            performAsync {
                Notes.Business.Effect.obtainNotes
            }
        }
    }
}

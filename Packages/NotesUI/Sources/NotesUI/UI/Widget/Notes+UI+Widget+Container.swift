import SwiftUI
import NotesReluxInt
import NotesReluxImpl
import NotesUIAPI
import SwiftUIRelux

public extension Notes.UI.Widget {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {
        // In SwiftUI-Relux, the Relux resolver injects all UI states into the root view.
        // If a state conforms to ObservableObject, it’s accessible via @EnvironmentObject.
        // If it’s declared using the @Observable macro, it’s available via @Environment.
        @EnvironmentObject private var notesState: Notes.UI.State
        @Environment(\.notesNavigation) private var nav
        
        public init() {

        }

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

// reactions
extension Notes.UI.Widget.Container {
    private func loadData() {
        if notesState.notesGroupedByDay.value.isNil {
            performAsync(delay: 0.5) {
                Notes.Business.Effect.obtainNotes
            }
        }
    }

    private func openList() async {
        await actions { nav.set(.list) }
    }
}

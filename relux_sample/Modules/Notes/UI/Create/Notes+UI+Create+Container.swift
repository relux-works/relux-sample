import SwiftUI

extension Notes.UI.Create {
    struct Container: Relux.UI.Container {
        @EnvironmentObject private var notesState: Notes.UI.State

        var body: some View {
            content
        }

        private var content: some View {
            Page(
                props: .init(),
                actions: .init()
            )
        }
    }
}

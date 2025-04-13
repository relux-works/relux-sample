import SwiftUI

extension Notes.UI.Widget.Container {
    struct Page: View {
        typealias Note = Notes.Business.Model.Note
        typealias Err = Notes.Business.Err

        let props: Props
        let actions: Actions

        var body: some View {
            content
        }

        private var content: some View {
            Text("Stub")
        }
    }
}

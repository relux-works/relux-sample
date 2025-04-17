import SwiftUI

extension SampleApp.UI.Main.Container {
    struct Page: View {
        var body: some View {
            content
        }
    }
}

extension SampleApp.UI.Main.Container.Page {
    private var content: some View {
        ScrollView {
            VStack {
                notesWidget
                Spacer()
            }
        }
    }

    private var notesWidget: some View {
        Notes.UI.Widget.Container()
    }
}

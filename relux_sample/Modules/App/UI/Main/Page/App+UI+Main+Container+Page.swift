import SwiftUI
import NotesReluxInt

extension SampleApp.UI.Main.Container {
    struct Page: Relux.UI.View {
        struct Props: Relux.UI.ViewProps {
            
        }
        let props: Props
        
        init(props: Props) {
            self.props = props
        }
        
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

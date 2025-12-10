import SwiftUI
import NotesReluxInt
import SwiftUIRelux

extension Notes.UI.Widget.Container {
    struct Page: Relux.UI.View {
        typealias Note = Notes.Business.Model.Note
        typealias Err = Notes.Business.Err

        let props: Props
        let actions: Actions

        var body: some View {
            content
                .animation(.easeInOut, value: props.notes.asAnimatableValue)
        }
    }
}

extension Notes.UI.Widget.Container.Page {
    private var content: some View {
        VStack {
            Text("Notes widget")
            Spacer()
            switch props.notes {
                case .initial: progressView
                case .failure: failureView
                case let .success(notes): notesView(count: notes.flatCount)
            }
        }
        .padding()
        .frame(height: 100)
        .background(.gray.opacity(0.3))
        .cornerRadius(28)
    }
}

// progress content
extension Notes.UI.Widget.Container.Page {
    private var progressView: some View {
        ProgressView("Loading ...")
            .extendingContent()
    }
}

// fail content
extension Notes.UI.Widget.Container.Page {
    private var failureView: some View {
        Text("Failed to load")
            .extendingContent()
    }
}

// notes content
extension Notes.UI.Widget.Container.Page {
    private func notesView(count: Int) -> some View {
        AsyncButton(action: actions.onOpenList) {
            notesContent(count: count)
        }
        .extendingContent()
    }

    @ViewBuilder
    private func notesContent(count: Int) -> some View {
        HStack {
            Text("Total notes")
            Spacer()
            Text(count.description)
        }.padding()
    }
}

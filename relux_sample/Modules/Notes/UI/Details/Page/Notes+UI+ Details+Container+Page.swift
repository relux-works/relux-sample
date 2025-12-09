import SwiftUI

extension Notes.UI.Details.Container {
    struct Page: View {
        typealias Note = Notes.Business.Model.Note
        typealias Err = Notes.Business.Err

        let props: Props
        let actions: Actions

        var body: some View {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// header
extension Notes.UI.Details.Container.Page {
    var title: Text {
        switch props.note.value {
            case .none: Text("Note")
            case let .some(data): switch data {
                case .none: Text("Note")
                case let .some(note): Text(note.title)
            }
        }
    }

    @ViewBuilder
    private func editBtn(for note: Note) -> some View {
        NavBarBtn.iconBtn(systemName: "square.and.pencil") {
            await actions.onEdit(note)
        }
    }
}
// subviews
extension Notes.UI.Details.Container.Page {
    private var content: some View {
        ScrollView {
            switch props.note {
                case .initial: progressView
                case .failure: failureView
                case let .success(note): switch note {
                    case .none: emptyView
                    case let .some(note): noteView(note)
                }
            }
        }
    }

    private var progressView: some View {
        ProgressView()
            .extendingContent()
    }

    private var failureView: some View {
        Text("Something went wrong :(")
            .extendingContent()
    }

    private var emptyView: some View {
        Text("Note doesn't exist")
            .extendingContent()
    }

    private func noteView(_ note: Note) -> some View {
        noteContent(note)
            .navigationBarItems(trailing: editBtn(for: note))
    }

    private func noteContent(_ note: Note) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            HStack {
                Text(note.title)
                    .font(.title2)
                Spacer()
            }
            
            Text(note.content)
                .font(.body)

            Text("Created at: \(note.createdAt.formatted(date: .numeric, time: .standard))")
                .font(.caption)
        }.padding()
    }
}


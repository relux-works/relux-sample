import SwiftUI

extension Notes.UI.Details.Container {
    struct Page: Relux.UI.View {
        typealias Note = Notes.Business.Model.Note
        typealias Err = Notes.Business.Err
        let props: Props
        let actions: Actions
        @State private var confirmDelete = false

        var body: some View {
            Group {
                switch props.note {
                case .initial: ProgressView("Loading note…")
                case .failure:
                    ContentUnavailableView {
                        Label("Couldn’t Load Note", systemImage: "exclamationmark.triangle")
                    } description: { Text("Try loading your notes again.") } actions: {
                        AsyncButton(action: actions.onReload) { Text("Try Again") }.buttonStyle(.bordered)
                    }
                case .success(nil):
                    ContentUnavailableView("Note Not Found", systemImage: "note.text",
                                           description: Text("This note is no longer in your session."))
                case .success(let note?):
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text(note.title).font(.title).bold().accessibilityAddTraits(.isHeader)
                            Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline).foregroundStyle(.secondary)
                            Text(note.content).textSelection(.enabled)
                            if let message = props.errorMessage {
                                Label(message, systemImage: "exclamationmark.triangle").foregroundStyle(.red)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading).padding()
                    }
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            AsyncButton(action: { await actions.onEdit(note) }) {
                                Label("Edit Note", systemImage: "square.and.pencil")
                            }
                        }
                        ToolbarItem(placement: .secondaryAction) {
                            Button("Delete Note", systemImage: "trash", role: .destructive) { confirmDelete = true }
                        }
                    }
                    .confirmationDialog("Delete note?", isPresented: $confirmDelete, titleVisibility: .visible) {
                        Button("Delete Note", role: .destructive) { Task { await actions.onRemove(note) } }
                        Button("Cancel", role: .cancel) { }
                    } message: { Text("“\(note.title)” will be removed from this session.") }
                }
            }
            .navigationTitle("Note")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

import SwiftUI

extension Notes.UI.List.Container {
    struct Page: Relux.UI.View {
        typealias Note = Notes.Business.Model.Note
        typealias Err = Notes.Business.Err
        let props: Props
        let actions: Actions
        @State private var search = ""
        @State private var noteToDelete: Note?

        var body: some View {
            let groups = props.groups(matching: search)
            List {
                if let message = props.errorMessage {
                    Section { Label(message, systemImage: "exclamationmark.triangle").foregroundStyle(.red) }
                }
                ForEach(groups, id: \.id) { group in
                    Section {
                        ForEach(group) { note in
                            Button { Task { await actions.onOpen(note.id) } } label: {
                                NoteRow(props: .init(title: note.title, content: note.content,
                                                     date: note.createdAt))
                            }
                            .tint(.primary)
                            .swipeActions(allowsFullSwipe: false) {
                                Button("Delete", systemImage: "trash", role: .destructive) { noteToDelete = note }
                            }
                            .contextMenu {
                                Button("Delete Note", systemImage: "trash", role: .destructive) { noteToDelete = note }
                            }
                        }
                    } header: {
                        if let date = group.first?.createdAt {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                }
                if !groups.isEmpty {
                    Section {
                        Text("In-memory demo. Changes reset when you restart the app.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
            .overlay {
                switch props.notes {
                case .initial:
                    ProgressView("Loading notes…")
                case .failure:
                    ContentUnavailableView {
                        Label("Couldn’t Load Notes", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text("Try loading your notes again.")
                    } actions: {
                        AsyncButton(action: actions.onReload) { Text("Try Again") }.buttonStyle(.bordered)
                    }
                case .success:
                    if groups.isEmpty {
                        if search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            ContentUnavailableView {
                                Label("Your Notes Start Here", systemImage: "note.text")
                            } description: {
                                Text("Capture an idea or make a quick checklist. Notes reset when the app restarts.")
                            } actions: {
                                AsyncButton(action: actions.onCreate) { Text("New Note") }.buttonStyle(.bordered)
                            }
                        } else {
                            ContentUnavailableView.search(text: search)
                        }
                    }
                }
            }
            .navigationTitle("Notes")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search titles and text")
            #else
            .searchable(text: $search, prompt: "Search titles and text")
            #endif
            .refreshable(action: actions.onReload.callAsFunction)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    AsyncButton(action: actions.onCreate) { Label("New Note", systemImage: "square.and.pencil") }
                        .keyboardShortcut("n", modifiers: .command)
                }
            }
            .confirmationDialog("Delete note?", isPresented: Binding(
                get: { noteToDelete != nil }, set: { if !$0 { noteToDelete = nil } }
            ), titleVisibility: .visible, presenting: noteToDelete) { note in
                Button("Delete Note", role: .destructive) { Task { await actions.onRemove(note) } }
                Button("Cancel", role: .cancel) { }
            } message: { note in
                Text("“\(note.title)” will be removed from this session.")
            }
        }
    }
}

private extension Notes.UI.List.Container.Page {
    struct NoteRow: Relux.UI.View {
        struct Props: Relux.UI.ViewProps {
            let title: String
            let content: String
            let date: Date
        }
        let props: Props

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(props.title).font(.headline)
                Text(props.content).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                Text(props.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityHint("Opens the note")
        }
    }
}

extension Array<Notes.Business.Model.Note> {
    public var id: Date? { first?.createdAt.startOfDay }
}

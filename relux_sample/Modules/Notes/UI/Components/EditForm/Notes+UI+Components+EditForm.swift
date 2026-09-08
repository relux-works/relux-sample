import SwiftUI

extension Notes.UI.Component {
    struct EditForm: Relux.UI.View {
        let props: Props
        let actions: Actions
        @State private var draft: Note
        @State private var isSaving = false
        @State private var confirmDiscard = false
        @FocusState private var focusedField: Field?

        private enum Field: Hashable { case title, body }

        init(props: Props, actions: Actions) {
            self.props = props
            self.actions = actions
            // An editing session owns a local copy. Only Save sends it back through a container.
            _draft = State(initialValue: props.note.map(Note.init(from:)) ?? Note())
        }

        private var hasChanges: Bool {
            if let note = props.note { return draft != Note(from: note) }
            return !draft.title.isEmpty || !draft.content.isEmpty
        }

        var body: some View {
            Form {
                Section("Title") {
                    TextField("Note title", text: $draft.title)
                        .accessibilityLabel("Note title")
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .body }
                }
                Section {
                    TextEditor(text: $draft.content)
                        .frame(minHeight: 180)
                        .accessibilityLabel("Note body")
                        .focused($focusedField, equals: .body)
                } header: {
                    Text("Note")
                } footer: {
                    Text("Add a title and some text to save. Notes stay in memory and reset when you restart the app.")
                }
                if let message = props.errorMessage {
                    Section {
                        Label(message, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }
                if isSaving {
                    Section { ProgressView("Saving note…") }
                }
            }
            .disabled(isSaving)
            .navigationTitle(props.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            #endif
            .interactiveDismissDisabled(hasChanges || isSaving)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasChanges { confirmDiscard = true }
                        else { Task { await actions.onCancel() } }
                    }
                    .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    // Pass the current draft as input so a stable callback cannot capture stale text.
                    SaveButton(props: .init(draft: draft, enabled: draft.valid && !isSaving),
                               actions: .init(onSave: ViewInputCallback(save)))
                }
                #if os(iOS)
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
                #endif
            }
            .confirmationDialog("Discard changes?", isPresented: $confirmDiscard, titleVisibility: .visible) {
                Button("Discard Changes", role: .destructive) { Task { await actions.onCancel() } }
                Button("Keep Editing", role: .cancel) { }
            }
        }

        private func save(_ draft: Note) async {
            guard draft.valid, !isSaving else { return }
            isSaving = true
            focusedField = nil
            await actions.onSave(draft.asNote(withId: props.note?.id ?? UUID()))
            isSaving = false
        }
    }
}

extension Notes.UI.Component.EditForm {
    struct SaveButton: Relux.UI.View {
        struct Props: Relux.UI.ViewProps {
            let draft: Notes.UI.Component.EditForm.Note
            let enabled: Bool
        }
        struct Actions: Relux.UI.ViewCallbacks { let onSave: ViewInputCallback<Notes.UI.Component.EditForm.Note> }
        let props: Props
        let actions: Actions

        var body: some View {
            Group {
                if #available(iOS 26, macOS 26, *) {
                    Button("Save") { Task { await actions.onSave(props.draft) } }
                        .buttonStyle(.glassProminent)
                } else {
                    Button("Save") { Task { await actions.onSave(props.draft) } }
                        .buttonStyle(.borderedProminent)
                }
            }
            .disabled(!props.enabled)
            .keyboardShortcut("s", modifiers: .command)
            .accessibilityHint("Saves the note for this app session")
        }
    }
}

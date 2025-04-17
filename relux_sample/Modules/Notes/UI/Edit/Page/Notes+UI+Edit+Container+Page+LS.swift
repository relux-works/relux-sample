import Combine

extension Notes.UI.Edit.Container.Page {
    @MainActor
    final class LocalState: ObservableObject {
        typealias FormNote =  Notes.UI.Component.EditForm.Note
        typealias Note =  Notes.Business.Model.Note

        @Published private(set) var initialNote: FormNote
        @Published var note: FormNote = .init()
        @Published private(set) var valid: Bool = false

        init(props: Props) {
            self.initialNote = .init(from: props.note)
            initPipelines()
        }

        private func initPipelines() {
            $initialNote
                .receive(on: mainQueue)
                .assign(to: &$note)

            $note
                .map(Self.validate)
                .receive(on: mainQueue)
                .assign(to: &$valid)
        }

        nonisolated
        private static func validate(note: FormNote) -> Bool {
            note.valid
        }
    }
}

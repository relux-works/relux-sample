import Combine
import NotesReluxInt
import SwiftUIRelux

extension Notes.UI.Create.Container.Page {
    @MainActor
    final class LocalState: ObservableObject {
        typealias FormNote =  Notes.UI.Component.EditForm.Note

        @Published var note: FormNote = .init()
        @Published private(set) var valid: Bool = false

        init() {
            initPipelines()
        }

        private func initPipelines() {
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
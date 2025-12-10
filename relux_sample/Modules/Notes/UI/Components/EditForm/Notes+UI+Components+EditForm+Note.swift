import NotesReluxInt
import SwiftUIRelux
extension Notes.UI.Component.EditForm {
    struct Note: Equatable, Hashable {
        var title: String
        var content: String
        var createdAt: Date

        init(
            title: String = "",
            content: String = "",
            createdAt: Date = .now
        ) {
            self.title = title
            self.content = content
            self.createdAt = createdAt
        }
    }
}

extension Notes.UI.Component.EditForm.Note {
    var asNote: Notes.Business.Model.Note {
        .init(
            id: .init(),
            createdAt: createdAt,
            title: title,
            content: content
        )
    }

    func asNote(withId: Notes.Business.Model.Note.Id) -> Notes.Business.Model.Note {
        .init(
            id: withId,
            createdAt: createdAt,
            title: title,
            content: content
        )
    }
}

extension Notes.UI.Component.EditForm.Note {
    var valid: Bool {
        self.title.isNotEmpty && self.content.isNotEmpty
    }
}

extension Notes.UI.Component.EditForm.Note {
    init(from note: Notes.Business.Model.Note) {
        self.title = note.title
        self.content = note.content
        self.createdAt = note.createdAt
    }
}
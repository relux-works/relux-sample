import SwiftUI
import NotesReluxInt
import SwiftUIRelux

extension Notes.UI.Component.EditForm {
    struct Props: ViewProps {
        let title: String
        var note: Binding<Note>
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.note.wrappedValue == rhs.note.wrappedValue &&
            lhs.title == rhs.title
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(note.wrappedValue)
        }
    }

    struct Actions: Relux.UI.ViewCallbacks {
       
    }
}
import SwiftUI

extension Notes.UI.Component.EditForm {
    struct Props: DynamicProperty {
        let title: String
        @Binding var note: Note
    }

    struct Actions: ViewActions {
        
    }
}

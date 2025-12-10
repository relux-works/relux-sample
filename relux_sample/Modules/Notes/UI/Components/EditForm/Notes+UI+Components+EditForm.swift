import SwiftUI

extension Notes.UI.Component {
    struct EditForm: Relux.UI.View {
        let props: Props
        let actions: Actions

        var body: some View {
            content
                .navigationTitle(props.title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension Notes.UI.Component.EditForm {
    private var content: some View {
        Form {
            TextField("Title", text: props.note.title)

            TextEditor(text: props.note.content)
                .frame(minHeight: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )

            DatePicker(
                "Created At",
                selection: props.note.createdAt,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
        }
    }
}

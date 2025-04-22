import SwiftUI

@MainActor
extension Notes.UI {
    @ViewBuilder
    static func handleRoute(for page: Notes.UI.Model.Page) -> some View {
        switch page {
            case .list: Notes.UI.List.Container()
            case let .details(id): Notes.UI.Details.Container(props: .init(id: id))
            case .create: Notes.UI.Create.Container()
            case let .edit(note): Notes.UI.Edit.Container(props: .init(note: note))
        }
    }
}

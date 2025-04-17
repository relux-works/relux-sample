import SwiftUI

extension SampleApp.UI.Main {
    @ViewBuilder
    static func handleRoute(for page: SampleApp.UI.Main.Model.Page) -> some View {
        switch page {
            case .main: Container()
            case .account: Account.UI.Container()
            case let .notes(page): Notes.UI.handleRoute(for: page)
        }
    }
}

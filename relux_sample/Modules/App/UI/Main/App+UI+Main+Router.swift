import SwiftUI

extension SampleApp.UI.Main {
    @ViewBuilder
    static func handleRoute(for page: SampleApp.UI.Main.Model.Page) -> some View {
        switch page {
            case .main: Container()
            case .settings: SampleApp.UI.Settings.Container()
        }
    }
}

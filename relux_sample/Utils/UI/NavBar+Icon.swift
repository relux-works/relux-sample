import SwiftUI

enum NavBar {
    @MainActor
    static func iconBtn(systemName: String, action: @escaping @Sendable () async -> Void) -> some View {
        AsyncButton(action: action) {
            Image(systemName: systemName)
        }
    }
}

import SwiftUI

enum NavBarBtn {
    @MainActor
    static func iconBtn(systemName: String, action: @escaping @Sendable () async -> Void) -> some View {
        AsyncButton(action: action) {
            Image(systemName: systemName)
        }
    }
}

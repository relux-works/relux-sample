import SwiftUI

extension SampleApp.UI.Main {
    struct Container: Relux.UI.Container {
        @Environment(Auth.Business.State.self) private var authState

        var body: some View {
            content
                .navigationBarBackButtonHidden()
                .navigationBarHidden(true)
        }

        private var content: some View {
            VStack {
                Text("Main \(authState.loggedIn.description)")
                Relux.NavigationLink(page: .app(page: .settings)) {
                    Text("Settings")
                }
            }
        }
    }
}

import Auth
import SwiftUI
import SwiftUIRelux

extension Auth.UI.Initial {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {

        var body: some View {
            ProgressView()
                .navigationBarBackButtonHidden()
                .navigationBarHidden(true)
                .task { await runLogoutFlow() }
        }
    }
}

extension Auth.UI.Initial.Container {
    private func runLogoutFlow() async {
        await actions {
            Auth.Business.Effect.runLogoutFlow
        }
    }
}

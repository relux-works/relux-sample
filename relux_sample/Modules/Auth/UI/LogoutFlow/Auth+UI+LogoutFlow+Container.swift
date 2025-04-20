import SwiftUI

extension Auth.UI.Initial {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {

        var body: some View {
            content
                .navigationBarBackButtonHidden()
                .navigationBarHidden(true)
        }

        private var content: some View {
            SampleApp.UI.Root.Splash()
                .task { await runLogoutFlow() }
        }
    }
}

extension Auth.UI.Initial.Container {
    private func runLogoutFlow() async {
        await action {
            Auth.Business.Effect.runLogoutFlow
        }
    }
}

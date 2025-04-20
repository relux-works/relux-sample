import SwiftUI

extension Auth.UI.LocalAuth {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {

        var body: some View {
            content
                .navigationBarBackButtonHidden()
                .navigationBarHidden(true)
        }

        private var content: some View {
            Page(
                props: .init(),
                actions: .init(
                    onTryLocalAuth: { await tryLocalAuth() }
                )
            )
        }
    }
}

extension Auth.UI.LocalAuth.Container {
    private func tryLocalAuth() async {
        await action {
            Auth.Business.Effect.authorizeWithBiometry
        }
    }
}

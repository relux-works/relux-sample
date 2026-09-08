import AuthReluxInt
import SwiftUI
import SwiftUIRelux

extension Auth.UI.LocalAuth {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {

        var body: some View {
            content
                .navigationBarBackButtonHidden()
                #if os(iOS)
                .toolbar(.hidden, for: .navigationBar)
                #endif
        }

        private var content: some View {
            Page(
                props: Page.Props(),
                actions: Page.Actions(
                    onTryLocalAuth: ViewCallback(tryLocalAuth)
                )
            )
        }
    }
}

extension Auth.UI.LocalAuth.Container {
    private func tryLocalAuth() async {
        await actions {
            Auth.Business.Effect.authorizeWithBiometry
        }
    }
}

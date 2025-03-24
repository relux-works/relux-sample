import SwiftUI

extension Auth.UI.LocalAuth {
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
                    onTryLocalAuth: tryLocalAuth
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

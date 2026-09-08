import SwiftUI

extension SampleApp.UI.Main {
    struct Container: Relux.UI.Container {
        var body: some View {
            Page(props: .init(), actions: .init(onOpenNotes: ViewCallback(openNotes),
                                                onOpenAccount: ViewCallback(openAccount)))
        }

        private func openNotes() async {
            await actions { AppRouter.Action.push(.app(page: .notes(.list))) }
        }

        private func openAccount() async {
            await actions { AppRouter.Action.push(.app(page: .account)) }
        }
    }
}

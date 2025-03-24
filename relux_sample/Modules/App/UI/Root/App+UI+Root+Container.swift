import SwiftUI

extension SampleApp.UI.Root {
    struct Container: Relux.UI.Container {
        @EnvironmentObject var appRouter: AppRouter

        var body: some View {
            content
        }

        @ViewBuilder
        private var content: some View {
            NavigationStack(path: $appRouter.path, root: rootView)
        }

        private func rootView() -> some View {
            Splash()
                .navigationDestination(for: AppPage.self, destination: SampleApp.UI.Root.handleRoute)
        }
    }
}

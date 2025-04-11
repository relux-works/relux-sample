import SwiftUI

extension SampleApp.UI.Root {
    struct Container: Relux.UI.Container {
        @EnvironmentObject var appRouter: AppRouter

        var body: some View {
            content
        }

        @ViewBuilder
        private var content: some View {
            VStack {
                switch appRouter.path.isEmpty {
                    case true:
                        Splash()
                            .transition(.opacity)
                    case false:
                        NavigationStack(path: $appRouter.path, root: rootView)
                            .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 1), value: appRouter.path.isEmpty)
        }

        private func rootView() -> some View {
            Splash()
                .navigationDestination(for: AppPage.self, destination: SampleApp.UI.Root.handleRoute)
        }
    }
}

import SwiftUI

extension SampleApp.UI.Root {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {
        // In SwiftUI-Relux, the Relux resolver injects all UI states into the root view.
        // If a state conforms to ObservableObject, it’s accessible via @EnvironmentObject.
        // If it’s declared using the @Observable macro, it’s available via @Environment.
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

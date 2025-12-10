import SwiftUI

extension SampleApp.UI.Root {
    // ReluxContainer separates the Relux-driven business layer from the SwiftUI view layer.
    struct Container: Relux.UI.Container {
        // In SwiftUI-Relux, the Relux resolver injects all UI states into the root view.
        // If a state conforms to ObservableObject, it’s accessible via @EnvironmentObject.
        // If it’s declared using the @Observable macro, it’s available via @Environment.
        @EnvironmentObject var appRouter: AppRouter
        @Environment(ModalRouter.self) private var modalRouter

        let relux: Relux

        var body: some View {
            content
                // simple way to centralised control of app modals
                .sheet(item: modalRouter.binding.modalSheet, content: modalPage)
        }

        @ViewBuilder
        private var content: some View {
            VStack {
                switch appRouter.path.isEmpty {
                    case true:
                        Splash(props: SampleApp.UI.Root.Splash.Props())
                            .transition(.opacity)
                    case false:
                        NavigationStack(path: $appRouter.path, root: rootView)
                            .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.1), value: appRouter.path.isEmpty)
        }

        private func rootView() -> some View {
            Splash(props: SampleApp.UI.Root.Splash.Props())
                .navigationDestination(for: AppPage.self) { SampleApp.UI.Root.RouterView(page: $0) }
        }
    }
}

// modal pages
extension SampleApp.UI.Root.Container {
    private func modalPage(for item: Navigation.Business.Model.ModalPage) -> some View {
        Group {
            switch item {
                case .debug: debugModal
            }
        }
        // we have to pass states into env to each modal, due to it's outside of our rootView hierarchy
        .passingObservableToEnvironment(fromStore: relux.store)
    }

    private var debugModal: some View {
        Text("Debug page")
    }
}

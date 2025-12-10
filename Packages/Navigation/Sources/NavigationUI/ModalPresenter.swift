import SwiftUI
import Relux
import SwiftUIRelux
import NavigationReluxInt

extension Navigation.UI {
    /// View modifier that handles modal presentation from ModalRouter state.
    public struct ModalPresenter<ModalContent: View>: ViewModifier {
        @EnvironmentObject private var nav: Relux.UI.ActionRelay<AppNavigation>

        let modalRouter: Navigation.Business.IModalRouter
        let content: (Navigation.Business.Model.ModalPage) -> ModalContent

        public init(
            modalRouter: Navigation.Business.IModalRouter,
            @ViewBuilder content: @escaping (Navigation.Business.Model.ModalPage) -> ModalContent
        ) {
            self.modalRouter = modalRouter
            self.content = content
        }

        public func body(content: Content) -> some View {
            content
                .sheet(
                    item: Binding(
                        get: { modalRouter.modalSheet },
                        set: { _ in
                            Task { await actions { nav.actions.dismiss() } }
                        }
                    )
                ) { page in
                    self.content(page)
                }
        }
    }
}

extension View {
    /// Attaches modal presentation handling to a view.
    ///
    /// Usage:
    /// ```swift
    /// ContentView()
    ///     .modalPresenter(router: navigationModule.modalRouter) { page in
    ///         switch page {
    ///         case .debug: DebugView()
    ///         }
    ///     }
    /// ```
    public func modalPresenter<ModalContent: View>(
        router: Navigation.Business.IModalRouter,
        @ViewBuilder content: @escaping (Navigation.Business.Model.ModalPage) -> ModalContent
    ) -> some View {
        modifier(Navigation.UI.ModalPresenter(modalRouter: router, content: content))
    }
}

import SwiftUI
import Relux
import NavigationReluxInt
import NavigationReluxImpl

extension Navigation.UI {
    /// View modifier that handles modal presentation from a generic ModalRouter.
    public struct ModalPresenter<
        Route: Relux.Navigation.PathComponent & Hashable & Sendable,
        Modal: Relux.Navigation.ModalComponent & Hashable & Sendable,
        ModalContent: View
    >: ViewModifier {

        @EnvironmentObject private var nav: Relux.UI.ActionRelay<NavigationActions<Route, Modal>>

        let modalRouter: Navigation.Business.ModalRouter<Modal>
        let modalContent: (Modal) -> ModalContent

        public init(
            modalRouter: Navigation.Business.ModalRouter<Modal>,
            @ViewBuilder content: @escaping (Modal) -> ModalContent
        ) {
            self.modalRouter = modalRouter
            self.modalContent = content
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
                    modalContent(page)
                }
        }
    }
}

extension View {
    /// Attaches modal presentation handling to a view.
    public func modalPresenter<
        Route: Relux.Navigation.PathComponent & Hashable & Sendable,
        Modal: Relux.Navigation.ModalComponent & Hashable & Sendable,
        ModalContent: View
    >(
        router: Navigation.Business.ModalRouter<Modal>,
        @ViewBuilder content: @escaping (Modal) -> ModalContent
    ) -> some View {
        modifier(Navigation.UI.ModalPresenter<Route, Modal, ModalContent>(modalRouter: router, content: content))
    }
}


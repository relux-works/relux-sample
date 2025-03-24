import SwiftUI

extension View {
    func navigate(to page: AppPage) -> some View {
        Relux.NavigationLink(page: page) { self }
    }
}

extension Relux {
    struct NavigationLink<Content: View>: View {
        private let page: AppPage
        private let onNavigated: (() async -> ())?
        @ViewBuilder private let content: () -> Content

        init(
            page: AppPage,
            onNavigated: (() async -> ())? = nil,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.page = page
            self.onNavigated = onNavigated
            self.content = content
        }

        var body: some View {
            AsyncButton(action: reactOnTap) {
                content()
            }
        }

        private func reactOnTap() async {
            await action {
                AppRouter.Action.push(page)
            }
            await onNavigated?()
        }
    }
}

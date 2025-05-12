import SwiftUI

/// Adds a navigation link to the view that pushes the given `AppPage`.
///
/// Usage:
/// ```swift
/// Text("Profile")
///     .navigate(to: .profile)
/// ```
extension View {
    func navigate(to page: AppPage) -> some View {
        Relux.NavigationLink(page: page) { self }
    }
}

/// `NavigationLink` bound to an `AppPage`.
///
/// Internally built on top of `AsyncButton`, so a tap is accepted only once
/// while the push animation is in progress. Attach it using `navigate(to:)`
/// on any view.

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
            await actions {
                AppRouter.Action.push(page)
            }
            await onNavigated?()
        }
    }
}

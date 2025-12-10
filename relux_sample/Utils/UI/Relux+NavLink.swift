import SwiftUI
import NavigationReluxImpl

/// Adds a navigation link to the view that pushes the given `InternalPage`.
///
/// Usage:
/// ```swift
/// Text("Profile")
///     .navigate(to: .app(page: .account))
/// ```
extension View {
    func navigate(to page: InternalPage) -> some View {
        Relux.NavigationLink(page: page) { self }
    }
}

/// `NavigationLink` bound to an `InternalPage`.
///
/// Internally built on top of `AsyncButton`, so a tap is accepted only once
/// while the push animation is in progress. Attach it using `navigate(to:)`
/// on any view.

extension Relux {
    struct NavigationLink<Content: View>: View {
        private let page: InternalPage
        private let onNavigated: (@Sendable () async -> ())?
        @ViewBuilder private let content: () -> Content

        init(
            page: InternalPage,
            onNavigated: (@Sendable () async -> ())? = nil,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.page = page
            self.onNavigated = onNavigated
            self.content = content
        }

        var body: some View {
            AsyncButton(action: Self.buildAction(page: page, onNavigated: onNavigated)) {
                content()
            }
        }

        /// Make the button action @Sendable and detach it from the
        /// view's generic type to silence strict-concurrency checks
        /// about capturing `Content.Type` in an isolated closure.
        private static func buildAction(
            page: InternalPage,
            onNavigated: (@Sendable () async -> ())?
        ) -> @Sendable () async -> Void {
            { @Sendable in
                await actions {
                    AppRouter.Action.push(page)
                }
                await onNavigated?()
            }
        }
    }
}

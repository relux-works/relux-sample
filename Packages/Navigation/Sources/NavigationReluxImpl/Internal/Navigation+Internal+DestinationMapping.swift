import NavigationReluxInt

extension Navigation.UI.Model.Destination {
    /// Maps public Destination to internal page structure.
    /// Returns nil for navigation commands (back, root).
    var asInternalPage: InternalPage? {
        switch self {
        case .back, .root:
            return nil // Commands, not pages
        case .splash:
            return .splash
        case .main:
            return .app(page: .main)
        case .account:
            return .app(page: .account)
        case .auth(let page):
            return .auth(page: page)
        case .notes(let page):
            return .app(page: .notes(page))
        }
    }

    /// Whether this destination is a navigation command vs actual page.
    var isCommand: Bool {
        switch self {
        case .back, .root: return true
        default: return false
        }
    }
}

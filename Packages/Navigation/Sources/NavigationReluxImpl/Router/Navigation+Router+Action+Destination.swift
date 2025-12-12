import Relux
import ReluxRouter
import NavigationReluxInt

/// Creates router action from Destination.
/// These are non-isolated so they can be called from @Sendable closures.  <- todo: think about this
public func makeRouterAction(for destination: Navigation.UI.Model.Destination) -> AppRouter.Action {
    switch destination {
    case .back:
        return .removeLast()
    case .root:
        return .set([])
    case .splash, .main, .account, .auth, .notes:
        guard let page = destination.asInternalPage else {
            fatalError("Destination \(destination) should have internal page mapping")
        }
        return .push(page)
    }
}

/// Creates replace action from Destination.
public func makeRouterReplaceAction(for destination: Navigation.UI.Model.Destination) -> AppRouter.Action {
    guard !destination.isCommand else {
        fatalError("Cannot replace with navigation command: \(destination)")
    }
    guard let page = destination.asInternalPage else {
        fatalError("Destination \(destination) should have internal page mapping")
    }
    return .set([page])
}

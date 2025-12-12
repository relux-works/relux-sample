import Relux
import NavigationReluxInt
import SwiftUIRelux

extension AppRouter {
    /// Creates router action from Destination.
    /// Commands (back, root) return pop actions; pages are pushed directly.
    nonisolated public static func action(for destination: Navigation.UI.Model.Destination) -> Action {
        switch destination {
        case .back:
            return .removeLast()
        case .root:
            return .set([])
        default:
            return .push(destination)
        }
    }

    /// Creates replace action from Destination.
    /// Only valid for pushable pages, not commands.
    nonisolated public static func replaceAction(for destination: Navigation.UI.Model.Destination) -> Action {
        guard !destination.isCommand else {
            fatalError("Cannot replace with navigation command: \(destination)")
        }
        return .set([destination])
    }
}

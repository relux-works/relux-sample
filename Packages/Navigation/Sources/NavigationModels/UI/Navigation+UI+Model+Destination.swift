import Relux
import AuthReluxInt
import NotesReluxInt
import NotesUIAPI

extension Navigation.UI.Model {
    /// Unified navigation destination for the entire app.
    /// All domains can navigate to any destination via this enum.
    ///
    /// Usage:
    /// ```swift
    /// nav.actions.go(.notes(.create))
    /// nav.actions.go(.auth(.localAuth))
    /// nav.actions.go(.back)
    /// ```
    public enum Destination: Sendable, Hashable {
        // MARK: - Navigation Commands
        /// Pop to previous screen
        case back
        /// Pop to root of current stack
        case root

        // MARK: - App Sections
        /// Splash/loading screen
        case splash
        /// Main app screen (after auth)
        case main
        /// Account screen
        case account

        // MARK: - Domain Entry Points
        /// Authentication flow
        case auth(Auth.UI.Model.Page = .logoutFlow)
        /// Notes domain
        case notes(Notes.UI.Model.Page = .list)
    }
}

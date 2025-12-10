import SwiftUI
import NotesReluxInt
import Relux

@MainActor
public protocol NotesUIProviding: Sendable {
    func view(for page: Notes.UI.Model.Page) -> AnyView
}

// Navigation adapter exposed to the app host.
public protocol NotesUIRouting: Sendable {
    func push(_ page: Notes.UI.Model.Page) -> any Relux.Action
    func set(_ page: Notes.UI.Model.Page) -> any Relux.Action
    func pop() -> any Relux.Action
}

@MainActor
public enum NotesUIRoutingRegistry {
    public static var router: NotesUIRouting?
}

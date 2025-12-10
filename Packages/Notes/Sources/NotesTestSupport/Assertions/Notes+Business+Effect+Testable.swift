import Foundation
import NotesReluxInt

extension Notes.Business.Effect {
    public enum Testable: Equatable {
        case notImplemented(_ uuid: UUID = .init())
    }

    public var testable: Testable {
        .notImplemented()
    }
}

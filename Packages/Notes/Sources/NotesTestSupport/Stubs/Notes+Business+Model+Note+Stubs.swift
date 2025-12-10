import Foundation
import NotesModels

extension Notes.Business.Model.Note {
    public static func stub(
        id: Id = .init(),
        createdAt: Date = .now,
        title: String? = nil,
        content: String? = nil
    ) -> Self {
        .init(
            id: id,
            createdAt: createdAt,
            title: title ?? "Title \(Int.random(in: 1...1_000))",
            content: content ?? "Content \(Int.random(in: 1...1_000))"
        )
    }
}

extension Array where Element == Notes.Business.Model.Note {
    public static func stub(count: Int = 3) -> Self {
        (0..<count).map { _ in .stub() }
    }
}

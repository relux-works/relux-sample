@testable import relux_sample

extension Notes.Business.Model.Note {
    static func stubRandom() -> Self {
        .init(
            id: .init(),
            createdAt: .now,
            title: "Title \(Int.random(in: 1...100))",
            content: "Content \(Int.random(in: 1...100))"
        )
    }
}

extension Sequence where Element == Notes.Business.Model.Note {
    static var stub: [Element] {
        [
            .stubRandom(),
            .stubRandom(),
            .stubRandom()
        ]
    }
}

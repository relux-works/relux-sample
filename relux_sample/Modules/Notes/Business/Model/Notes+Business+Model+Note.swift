extension Notes.Business.Model {
    struct Note {
        typealias Id = UUID

        let id: Id
        let createdAt: Date
        let title: String
        let content: String
    }
}

extension Notes.Business.Model.Note: Identifiable {}

extension Notes.Business.Model.Note: Sendable {}

extension Notes.Business.Model.Note: Equatable {}

extension Notes.Business.Model.Note: Hashable {}

extension Notes.Business.Model.Note: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}

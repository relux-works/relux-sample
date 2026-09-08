extension Notes.Business.Model {
    struct Note {
        typealias Id = UUID

        let id: Id
        let createdAt: Date
        let title: String
        let content: String
        var isProtected: Bool = false
        var isLocked: Bool = false
    }
}

extension Notes.Business.Model.Note {
    // The service and editor share the same content rule; the domain has no UI dependency.
    static func hasValidContent(title: String, content: String) -> Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension Notes.Business.Model.Note {
    init(from apiModel: Notes.Data.Api.DTO.Note) {
        self.id = apiModel.id
        self.createdAt = apiModel.date
        self.title = apiModel.title
        self.content = apiModel.content
        self.isProtected = apiModel.isProtected
        self.isLocked = apiModel.isLocked
    }
}

extension Notes.Business.Model.Note {
    var asDto: Notes.Data.Api.DTO.Note {
        .init(
            id: self.id,
            date: self.createdAt,
            title: self.title,
            content: self.content
        )
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

extension Notes.Business.Model.Note {
    var editableNote: Self? { isLocked ? nil : self }
}

extension Notes.Business {
    struct Snapshot: Sendable, Equatable {
        let revision: UInt64
        let notes: [Model.Note]
    }
}

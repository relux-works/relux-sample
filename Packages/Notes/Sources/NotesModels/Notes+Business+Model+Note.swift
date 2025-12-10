import Foundation

extension Notes.Business.Model {
    public struct Note: Sendable, Equatable, Hashable, Identifiable, Comparable {
        public typealias Id = UUID

        public let id: Id
        public let createdAt: Date
        public let title: String
        public let content: String

        public init(id: Id, createdAt: Date, title: String, content: String) {
            self.id = id
            self.createdAt = createdAt
            self.title = title
            self.content = content
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.createdAt < rhs.createdAt
        }
    }
}

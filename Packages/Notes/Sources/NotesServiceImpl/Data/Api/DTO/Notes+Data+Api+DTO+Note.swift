import Foundation
import NotesModels

extension Notes.Data.Api.DTO {
    public struct Note: Sendable, Equatable, Identifiable, Hashable {
        public typealias Id = Notes.Business.Model.Note.Id

        public let id: Id
        public let date: Date
        public let title: String
        public let content: String

        public init(id: Id, date: Date, title: String, content: String) {
            self.id = id
            self.date = date
            self.title = title
            self.content = content
        }
    }
}

extension Notes.Business.Model.Note {
    init(from apiModel: Notes.Data.Api.DTO.Note) {
        self.init(
            id: apiModel.id,
            createdAt: apiModel.date,
            title: apiModel.title,
            content: apiModel.content
        )
    }

    var asDto: Notes.Data.Api.DTO.Note {
        .init(
            id: self.id,
            date: self.createdAt,
            title: self.title,
            content: self.content
        )
    }
}

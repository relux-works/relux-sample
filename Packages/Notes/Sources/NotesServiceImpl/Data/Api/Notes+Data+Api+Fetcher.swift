import Foundation
import NotesModels

extension Notes.Data.Api {
    public protocol IFetcher: Sendable {
        typealias Err = Notes.Business.Err
        typealias DTO = Notes.Data.Api.DTO

        func getNotes() async -> Result<[DTO.Note], Err>
        func upsert(note: DTO.Note) async -> Result<Void, Err>
        func deletetNote(by id: DTO.Note.Id) async -> Result<Void, Err>
    }
}

extension Notes.Data.Api {
    public actor Fetcher {
        private var notes: [DTO.Note.Id: DTO.Note] = {
            let seed: [DTO.Note] = [
                .init(id: .init(), date: .now, title: "title 1", content: "content 1"),
                .init(id: .init(), date: .now.adding(minutes: -1), title: "title 2", content: "content 2"),
                .init(id: .init(), date: .now.adding(days: -1), title: "title 3", content: "content 3"),
                .init(id: .init(), date: .now.adding(days: -2), title: "title 4", content: "content 4"),
                .init(id: .init(), date: .now.adding(days: -2).adding(hours: -2).adding(minutes: -2), title: "title 5", content: "content 5"),
            ]
            return seed.keyed(by: \.id)
        }()

        public init() {}
    }
}

extension Notes.Data.Api.Fetcher: Notes.Data.Api.IFetcher {
    public func getNotes() async -> Result<[DTO.Note], Err> {
        .success(Array(notes.values))
    }

    public func upsert(note: DTO.Note) async -> Result<Void, Err> {
        notes[note.id] = note
        return .success(())
    }

    public func deletetNote(by id: DTO.Note.Id) async -> Result<Void, Err> {
        notes.removeValue(forKey: id)
        return .success(())
    }
}

extension Notes.Data.Api {
    public actor TestFetcher {
        private var notes: [DTO.Note.Id: DTO.Note] = {
            let seed: [DTO.Note] = [
                .init(id: .init(), date: .now, title: "title 1", content: "content 1"),
                .init(id: .init(), date: .now.adding(days: -2).adding(hours: -2).adding(minutes: -2), title: "title 5", content: "content 5"),
            ]
            return seed.keyed(by: \.id)
        }()

        public init() {}
    }
}

extension Notes.Data.Api.TestFetcher: Notes.Data.Api.IFetcher {
    public func getNotes() async -> Result<[DTO.Note], Err> {
        .success(Array(notes.values))
    }

    public func upsert(note: DTO.Note) async -> Result<Void, Err> {
        notes[note.id] = note
        return .success(())
    }

    public func deletetNote(by id: DTO.Note.Id) async -> Result<Void, Err> {
        notes.removeValue(forKey: id)
        return .success(())
    }
}

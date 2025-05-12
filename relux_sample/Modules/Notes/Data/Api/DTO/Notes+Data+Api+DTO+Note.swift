extension Notes.Data.Api.DTO {
    struct Note: Codable {
        typealias Id = UUID
        
        let id: Id
        let date: Date
        let title: String
        let content: String
    }
}

extension Notes.Data.Api.DTO.Note {
    enum Err: Error {
        case failedToDecode(_ msg: String)
        case failedToEncode(_ msg: String)
    }
}

extension Notes.Data.Api.DTO.Note {
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case title
        case content
    }
}

extension Notes.Data.Api.DTO.Note {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        let dateStr = try container.decode(String.self, forKey: .date)
        self.date = switch dateStr.utcStringAsLocalDate {
            case let .some(date): date
            case .none: throw Err.failedToDecode("date from \(dateStr)")
        }
    }
}

extension Notes.Data.Api.DTO.Note {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(date.localDateAsUtcString, forKey: .date)
    }
}

import Foundation

public extension Formatter {
    static let utcFormatter: ISO8601DateFormatter = {
        ISO8601DateFormatter()
    }()

    static let utcWithMSFormatter: ISO8601DateFormatter = {
        var formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter
    }()
}

public extension String {
    var utcStringAsLocalDate: Date? {
        Formatter.utcFormatter.date(from: self)
    }

    var utcWithMillisecStringAsLocalDate: Date? {
        Formatter.utcWithMSFormatter.date(from: self)
    }
}

public extension Date {
    var localDateAsUtcString: String {
        Formatter.utcFormatter.string(from: self)
    }

    var localDateAsUtcWithMillisecString: String {
        Formatter.utcWithMSFormatter.string(from: self)
    }
}

extension ISO8601DateFormatter: @retroactive @unchecked Sendable { }

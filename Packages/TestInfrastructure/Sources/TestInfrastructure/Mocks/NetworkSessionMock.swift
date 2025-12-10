import Foundation

public final class NetworkSessionMock: @unchecked Sendable {
    public var dataHandler: ((URLRequest) async throws -> (Data, URLResponse))?
    public private(set) var dataCallCount = 0

    public init() {}

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataCallCount += 1
        guard let handler = dataHandler else {
            fatalError("dataHandler not set")
        }
        return try await handler(request)
    }
}

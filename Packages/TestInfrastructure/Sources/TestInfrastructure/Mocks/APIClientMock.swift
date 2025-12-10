import Foundation

public protocol APIClientProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T
}

public protocol Endpoint: Sendable {}

public final class APIClientMock: APIClientProtocol, @unchecked Sendable {
    public var requestHandler: ((any Endpoint) async throws -> Any)?
    public private(set) var requestCallCount = 0
    public private(set) var capturedEndpoints: [any Endpoint] = []

    public init() {}

    public func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        requestCallCount += 1
        capturedEndpoints.append(endpoint)
        guard let handler = requestHandler else {
            fatalError("requestHandler not set")
        }
        return try await handler(endpoint) as! T
    }
}

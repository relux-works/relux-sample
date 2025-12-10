#if canImport(HttpClient)
import Foundation
import HttpClient

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public actor WSClientMock: IWSClient {
    public init() {}

    public var connectResult: Result<AsyncStream<Result<Data, WSClientError>>, WSClientError> = .failure(.notConfigured)
    public var sendResult: Result<Void, WSClientError> = .success(())
    public private(set) var disconnectCalled = false

    public func connect(to urlPath: String, with headers: Headers) async -> Result<AsyncStream<Result<Data, WSClientError>>, WSClientError> {
        connectResult
    }

    public func disconnect() async {
        disconnectCalled = true
    }

    public func send(_ message: String) async -> Result<Void, WSClientError> { sendResult }

    public func send(_ data: Data) async -> Result<Void, WSClientError> { sendResult }
}
#endif

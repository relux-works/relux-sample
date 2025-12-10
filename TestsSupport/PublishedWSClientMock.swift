import Foundation
import Combine
import HttpClient

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public actor PublishedWSClientMock: IPublishedWSClient {
    public typealias Config = PublishedWSClient.Config
    public typealias Err = WSClientError

    public init() {}

    public var configureResult: Result<Void, Err> = .success(())
    public var connectResult: Result<Void, Err> = .success(())
    public var sendResult: Result<Void, Err> = .success(())
    public var disconnectCalled = false

    private let msgSubject = PassthroughSubject<Result<Data?, Err>, Never>()
    private let statusSubject = CurrentValueSubject<ConnectionStatus, Never>(.initial)

    public func configure(with config: Config) async -> Result<Void, Err> { configureResult }
    public func connect() async -> Result<Void, Err> { connectResult }
    public func reconnect() async { }
    public func disconnect() async { disconnectCalled = true }

    public func send(_ message: String) async -> Result<Void, Err> { sendResult }
    public func send(_ data: Data) async -> Result<Void, Err> { sendResult }

    public var msgPublisher: AnyPublisher<Result<Data?, Err>, Never> {
        get async { msgSubject.eraseToAnyPublisher() }
    }

    public var connectionPublisher: Published<ConnectionStatus>.Publisher {
        get async { statusSubject.publisher }
    }

    // Helpers for tests
    public func emitMessage(_ result: Result<Data?, Err>) async { msgSubject.send(result) }
    public func setStatus(_ status: ConnectionStatus) async { statusSubject.send(status) }
}

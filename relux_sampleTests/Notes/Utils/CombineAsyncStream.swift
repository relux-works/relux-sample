import Combine
import Foundation

public class CombineAsyncStream<Upstream: Publisher>: AsyncSequence where Upstream.Output: Sendable {
    public typealias Element = Upstream.Output
    public typealias AsyncIterator = CombineAsyncStream<Upstream>
    private let stream: AsyncStream<Upstream.Output>
    private lazy var iterator = stream.makeAsyncIterator()
    private var cancellable: AnyCancellable?

    public init(_ upstream: Upstream) {
        var subscription: AnyCancellable? = nil

        stream = AsyncStream { continuation in
            subscription = upstream
                .handleEvents(
                    receiveCancel: { continuation.finish() }
                )
                .sink(
                    receiveCompletion: {
                        switch $0 {
                        case .failure:continuation.finish()
                        case .finished: continuation.finish()
                        }
                    },
                    receiveValue: { continuation.yield($0) }
                )
        }

        cancellable = subscription
    }


    public func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
}

extension CombineAsyncStream: AsyncIteratorProtocol {
    public func next() async throws -> Upstream.Output? {
        await iterator.next()
    }

    public func makeAsyncIterator() -> Self { self }
}

public extension Publisher where Output: Sendable {
    var asAsyncStream : CombineAsyncStream<Self> {
        CombineAsyncStream(self)
    }
}

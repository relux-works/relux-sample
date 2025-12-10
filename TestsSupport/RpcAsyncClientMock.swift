import Foundation
import HttpClient

/// Async RPC client mock; configurable results and call tracking.
public actor RpcAsyncClientMock: IRpcAsyncClient {
    public init() {}

    public private(set) var getCalls: [(url: URL, headers: Headers, retrys: RetryParams?)] = []
    public private(set) var performCalls: [Call] = []

    public var getResult: Result<ApiResponse, ApiError> = .failure(.init(sender: "RpcAsyncClientMock", endpoint: .init(path: "get", type: .get)))
    public var performResult: Result<ApiResponse, ApiError> = .failure(.init(sender: "RpcAsyncClientMock", endpoint: .init(path: "perform", type: .get)))

    public func setGetResult(_ result: Result<ApiResponse, ApiError>) { getResult = result }
    public func setPerformResult(_ result: Result<ApiResponse, ApiError>) { performResult = result }

    // MARK: IRpcAsyncClient
    public func get(url: URL, headers: Headers, fileID: String, functionName: String, lineNumber: Int) async -> Result<ApiResponse, ApiError> {
        getCalls.append((url: url, headers: headers, retrys: .none))
        return getResult
    }

    public func get(url: URL, headers: Headers, retrys: RequestRetrys, fileID: String, functionName: String, lineNumber: Int) async -> Result<ApiResponse, ApiError> {
        getCalls.append((url: url, headers: headers, retrys: .init(count: retrys.count, delay: retrys.delay)))
        return getResult
    }

    public func get(url: URL, headers: Headers, retrys: RetryParams, fileID: String, functionName: String, lineNumber: Int) async -> Result<ApiResponse, ApiError> {
        getCalls.append((url: url, headers: headers, retrys: retrys))
        return getResult
    }

    public func performAsync(endpoint: ApiEndpoint, headers: Headers, queryParams: QueryParams, bodyData: Data?) async -> Result<ApiResponse, ApiError> {
        performCalls.append(.init(endpoint: endpoint, headers: headers, queryParams: queryParams, bodyData: bodyData, retrys: .none))
        return performResult
    }

    public func performAsync(endpoint: ApiEndpoint, headers: Headers, queryParams: QueryParams, bodyData: Data?, fileID: String, functionName: String, lineNumber: Int) async -> Result<ApiResponse, ApiError> {
        performCalls.append(.init(endpoint: endpoint, headers: headers, queryParams: queryParams, bodyData: bodyData, retrys: .none))
        return performResult
    }

    public func performAsync(endpoint: ApiEndpoint, headers: Headers, queryParams: QueryParams, bodyData: Data?, retrys: RequestRetrys, fileID: String, functionName: String, lineNumber: Int) async -> Result<ApiResponse, ApiError> {
        performCalls.append(.init(endpoint: endpoint, headers: headers, queryParams: queryParams, bodyData: bodyData, retrys: .init(count: retrys.count, delay: retrys.delay)))
        return performResult
    }

    public func performAsync(endpoint: ApiEndpoint, headers: Headers, queryParams: QueryParams, bodyData: Data?, retrys: RetryParams, fileID: String, functionName: String, lineNumber: Int) async -> Result<ApiResponse, ApiError> {
        performCalls.append(.init(endpoint: endpoint, headers: headers, queryParams: queryParams, bodyData: bodyData, retrys: retrys))
        return performResult
    }
}

public extension RpcAsyncClientMock {
    struct Call: Sendable {
        public let endpoint: ApiEndpoint
        public let headers: Headers
        public let queryParams: QueryParams
        public let bodyData: Data?
        public let retrys: RetryParams?
    }
}

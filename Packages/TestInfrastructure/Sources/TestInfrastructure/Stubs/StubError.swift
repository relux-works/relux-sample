public struct StubError: Error, Equatable {
    public let message: String
    
    public init(_ message: String = "stub error") {
        self.message = message
    }
}

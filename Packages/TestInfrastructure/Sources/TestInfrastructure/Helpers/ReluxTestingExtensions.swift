import Relux

extension Relux.Testing.Logger {
    /// Find first action matching predicate
    public func findAction<A: Relux.Action>(
        _ type: A.Type,
        where predicate: (A) -> Bool
    ) -> A? {
        actions
            .compactMap { $0 as? A }
            .first(where: predicate)
    }
    
    /// Find first effect matching predicate
    public func findEffect<E: Relux.Effect>(
        _ type: E.Type,
        where predicate: (E) -> Bool
    ) -> E? {
        effects
            .compactMap { $0 as? E }
            .first(where: predicate)
    }
    
    /// Assert action was dispatched
    public func assertDispatched<A: Relux.Action>(
        _ type: A.Type,
        where predicate: (A) -> Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard findAction(type, where: predicate) != nil else {
            fatalError("Expected action not found", file: file, line: line)
        }
    }
}

public extension Array {
    /// Dictionary keyed by a property/keyPath. Later elements overwrite earlier ones.
    func keyed<Key: Hashable>(by keyPath: KeyPath<Element, Key>) -> [Key: Element] {
        var dict: [Key: Element] = [:]
        for element in self {
            dict[element[keyPath: keyPath]] = element
        }
        return dict
    }

    /// Groups adjacent elements while predicate returns true for `(previous, next)`.
    func chunked(adjoining areInSameGroup: (Element, Element) -> Bool) -> [[Element]] {
        guard var currentGroup = self.first.map({ [$0] }) else { return [] }
        var result: [[Element]] = []

        for element in self.dropFirst() {
            if let last = currentGroup.last, areInSameGroup(last, element) {
                currentGroup.append(element)
            } else {
                result.append(currentGroup)
                currentGroup = [element]
            }
        }
        result.append(currentGroup)
        return result
    }
}

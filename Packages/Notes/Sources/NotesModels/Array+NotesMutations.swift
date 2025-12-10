public extension Array where Element: Identifiable {
    mutating func upsertByIdentity(_ element: Element) {
        if let index = firstIndex(where: { $0.id == element.id }) {
            self.append(element)
            swapAt(index, count - 1)
            removeLast()
        } else {
            append(element)
        }
    }

    mutating func removeById(_ element: Element) {
        self = filter { $0.id != element.id }
    }
}

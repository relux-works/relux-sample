//
//  File.swift
//  relux_sample
//
//


extension ArraySlice {
    public var asArray: Array<Element> {
        Array(self)
    }
}

public extension Sequence {
    func groupBy<G: Hashable>(groupClosure : (Element) -> G) -> [G: [Element]] {
        Dictionary (grouping: self, by: groupClosure)
    }
}

public extension Collection {
	/// Returns the element at the specified index if it is within bounds, otherwise nil.
	subscript(safe index: Index) -> Element? {
		guard startIndex <= index && index < endIndex else { return nil }
		return self[index]
	}
}

public extension Collection {

    var hasMany: Bool {
        self.count > 1
    }
    var hasOne: Bool {
        self.count == 1
    }
    var isNotEmpty: Bool {
        !isEmpty
    }
}

public extension Array {
    mutating func insert(_ elem: Element) where Element: Equatable {
        self.append(elem)
    }

    mutating func upsert(_ elems: [Element]) where Element: Equatable {
        elems.forEach { self.upsert($0) }
    }

    mutating func upsert(_ elem: Element) where Element: Equatable {
        if let index = self.firstIndex(of: elem) {
            self.append(elem)
            self.swapAt(index, self.count - 1)
            self.removeLast()
        } else {
            self.append(elem)
        }
    }

    mutating func upsertByIdentity(_ elem: Element) where Element: Identifiable {
        if let index = self.firstIndex(where: { $0.id == elem.id }) {
            self.append(elem)
            self.swapAt(index, self.count - 1)
            self.removeLast()
        } else {
            self.append(elem)
        }
    }

    mutating func remove(_ elem: Element) where Element: Equatable {
        if let index = self.firstIndex(of: elem),
           index < self.count {
            self.swapAt(index, self.count - 1)
            self.removeLast()
        }
    }
    mutating func removeById(_ elem: Element) where Element: Identifiable {
        self = self.filter { $0.id != elem.id }
    }

    func take(_ take: Int, skip: Int = 0) -> Array<Element> {
        Array(self[skip..<skip+Swift.min(take, self.count-skip)])
    }

    func distinct<T: Hashable>(byKey key: (Element) -> T) -> [Element] {
        var result = [Element]()
        var seen = Set<T>()

        for value in self {
            if seen.insert(key(value)).inserted {
                result.append(value)
            }
        }

        return result
    }

    func concat(_ another: Array) -> [Element] {
        self + another
    }

    func isLast(_ elem: Element) -> Bool where Element: Equatable {
        self.last == elem
    }
    func isFirst(_ elem: Element) -> Bool where Element: Equatable {
        self.first == elem
    }
}

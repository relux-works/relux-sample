extension Sequence where Element: Collection {
    var flatCount: Int {
        reduce(0) { result, inner in
            result + inner.count
        }
    }
}

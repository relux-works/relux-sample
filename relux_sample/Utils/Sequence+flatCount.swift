import Foundation

extension Sequence where Element: Collection {
    var flatCount: Int {
        self.reduce(0) { result, innerArr in
            result + innerArr.count
        }
    }
}

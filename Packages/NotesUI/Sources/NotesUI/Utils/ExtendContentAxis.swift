import SwiftUI

struct ExtendContentAxis: OptionSet {
    static let vertical: ExtendContentAxis = ExtendContentAxis(rawValue: 1)
    static let horizontal: ExtendContentAxis = ExtendContentAxis(rawValue: 2)
    static let all: ExtendContentAxis = [.vertical, .horizontal]

    init(rawValue: Int8) {
        self.rawValue = rawValue
    }

    var rawValue: Int8
}

extension ExtendContentAxis: Sendable {}

extension View {
    func extendingContent(_ edges: ExtendContentAxis = .all) -> some View {
        VStack(spacing: 0) {
            if edges.contains(.horizontal) {
                HStack(spacing: 0) { Spacer(minLength: 0) }
            }
            if edges.contains(.vertical) {
                Spacer(minLength: 0)
            }
            self
            if edges.contains(.vertical) {
                Spacer(minLength: 0)
            }
        }
    }
}

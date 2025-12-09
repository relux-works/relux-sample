//
//  ExtendContentAxis.swift
//  relux_sample
//
//


import SwiftUI

public struct ExtendContentAxis: OptionSet {
    public static let vertical: ExtendContentAxis = ExtendContentAxis(rawValue: 1)
    public static let horizontal: ExtendContentAxis = ExtendContentAxis(rawValue: 2)
    public static let all: ExtendContentAxis = [.vertical, .horizontal]
    
    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
    
    public var rawValue: Int8
}

extension ExtendContentAxis: Sendable { }

public extension View {
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

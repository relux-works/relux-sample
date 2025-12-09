//
//  NavBar.swift
//  relux_sample
//
//


import SwiftUI

public struct NavBar<Middle: View, Leading: View, Trailing: View>: View {
    private let middle: () -> Middle
    private let leading: () -> Leading
    private let trailing: () -> Trailing
    private let alignment: Alignment

    public init(
            middle: @escaping () -> Middle,
            leading: @escaping () -> Leading,
            trailing: @escaping () -> Trailing,
            alignment: Alignment
    ) {
        self.leading = leading
        self.trailing = trailing
        self.middle = middle
        self.alignment = alignment
    }

    #warning("using zstack impacts layers")
    // e.g. middle content draws on top of leading
    // which is not obvious from point of use
    // may need another logic or zIndex priority exposed in api
    public var body: some View {
        ZStack(alignment: alignment) {
            HStack(spacing: 0) { leading(); Spacer(minLength: 0);}
            HStack(spacing: 0) { middle();}
            HStack(spacing: 0) { Spacer(minLength: 0); trailing();}
        }
    }
}

@available(iOS 15, *)
public extension View {
    func navBar() -> some View {
        self
    }

    func navBar<Middle>(middle: Middle, edge: VerticalEdge = .top, alignment: Alignment = .center) -> some View where Middle: View {
        self.navBar(middle: middle, leading: EmptyView(), trailing: EmptyView(), edge: edge, alignment: alignment)
    }

    func navBar<Leading>(leading: Leading, edge: VerticalEdge = .top, alignment: Alignment = .center) -> some View where Leading: View {
        self.navBar(middle: EmptyView(), leading: leading, trailing: EmptyView(), edge: edge, alignment: alignment)
    }

    func navBar<Trailing>(trailing: Trailing, edge: VerticalEdge = .top, alignment: Alignment = .center) -> some View where Trailing: View {
        self.navBar(middle: EmptyView(), leading: EmptyView(), trailing: trailing, edge: edge, alignment: alignment)
    }

    func navBar<Middle, Leading>(leading: Leading, middle: Middle, edge: VerticalEdge = .top, alignment: Alignment = .center) -> some View where Middle: View, Leading: View {
        self.navBar(middle: middle, leading: leading, trailing: EmptyView(), edge: edge, alignment: alignment)
    }

    func navBar<Middle, Trailing>(middle: Middle, trailing: Trailing, edge: VerticalEdge = .top, alignment: Alignment = .center) -> some View where Middle: View, Trailing: View {
        self.navBar(middle: middle, leading: EmptyView(), trailing: trailing, edge: edge, alignment: alignment)
    }

    func navBar<Leading, Trailing>(leading: Leading, trailing: Trailing, edge: VerticalEdge = .top, alignment: Alignment = .center) -> some View where Leading: View, Trailing: View {
        self.navBar(middle: EmptyView(), leading: leading, trailing: trailing, edge: edge, alignment: alignment)
    }

    func navBar<Middle, Leading, Trailing>(middle: Middle, leading: Leading, trailing: Trailing, edge: VerticalEdge = .top, alignment: Alignment = .center)
            -> some View
            where Middle: View, Leading: View, Trailing: View {
        self
                .safeAreaInset(edge: edge) {
                    NavBar(
                            middle: { middle },
                            leading: { leading },
                            trailing: { trailing },
                            alignment: alignment
                    )
                }
    }
}

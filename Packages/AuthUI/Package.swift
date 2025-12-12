// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AuthUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AuthUIAPI", targets: ["AuthUIAPI"]),
        .library(name: "AuthUI", targets: ["AuthUI"])
    ],
    dependencies: [
        .package(name: "AuthUI-Self", path: "."),
        .package(path: "../Auth"),
        .package(url: "https://github.com/ivalx1s/swiftui-relux.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "AuthUIAPI",
            dependencies: [
                .product(name: "AuthModels", package: "Auth"),
                .product(name: "AuthReluxInt", package: "Auth")
            ]
        ),
        .target(
            name: "AuthUI",
            dependencies: [
                .product(name: "AuthUIAPI", package: "AuthUI-Self"),
                .product(name: "AuthReluxInt", package: "Auth"),
                .product(name: "SwiftUIRelux", package: "swiftui-relux")
            ]
        )
    ]
)

// MARK: - Manifest-time API/Impl boundary guardrails

private func findDepName(in value: Any, depth: Int = 0) -> String? {
    if depth > 4 { return nil }
    let mirror = Mirror(reflecting: value)
    for child in mirror.children {
        if child.label == "name", let s = child.value as? String {
            return s
        }
        if let s = findDepName(in: child.value, depth: depth + 1) {
            return s
        }
    }
    return nil
}

func depName(_ dep: Target.Dependency) -> String {
    if let s = findDepName(in: dep) {
        return s
    }
    let mirror = Mirror(reflecting: dep)
    if let firstString = mirror.children.compactMap({ $0.value as? String }).first {
        return firstString
    }
    return String(describing: dep)
}

func isImpl(_ name: String) -> Bool {
    name.hasSuffix("Impl") || name.hasSuffix("Implementation")
}

func isAPI(_ name: String) -> Bool {
    name.hasSuffix("Int") || name.hasSuffix("API")
}

func isUI(_ name: String) -> Bool {
    name.hasSuffix("UI") || (name.contains("UI") && !isAPI(name))
}

let implAllowedTargets: Set<String> = []

for t in package.targets {
    guard t.type != .plugin && t.type != .binary else { continue }

    let tName = t.name
    let deps = t.dependencies.map(depName)

    if isAPI(tName), deps.contains(where: isImpl) {
        preconditionFailure(
            "❌ \(tName) is an API target and must not depend on Impl targets. Found: \(deps.filter(isImpl))"
        )
    }

    if isUI(tName), deps.contains(where: isImpl) {
        preconditionFailure(
            "❌ \(tName) is a UI target and must not depend on Impl targets. Found: \(deps.filter(isImpl))"
        )
    }

    if !implAllowedTargets.contains(tName), deps.contains(where: isImpl) {
        preconditionFailure(
            "❌ \(tName) depends on Impl targets, but only composition-root targets may do that. Found: \(deps.filter(isImpl))"
        )
    }
}

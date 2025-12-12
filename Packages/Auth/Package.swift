// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Auth",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AuthModels", type: .dynamic, targets: ["AuthModels"]),
        .library(name: "AuthReluxInt", type: .dynamic, targets: ["AuthReluxInt"]),
        .library(name: "AuthReluxImpl", type: .dynamic, targets: ["AuthReluxImpl"]),
        .library(name: "AuthServiceInt", type: .dynamic, targets: ["AuthServiceInt"]),
        .library(name: "AuthServiceImpl", type: .dynamic, targets: ["AuthServiceImpl"]),
        // Test-only helpers (static is fine)
        .library(name: "AuthTestSupport", targets: ["AuthTestSupport"]),
    ],
    dependencies: [
        // Dev note: self-reference forces dynamic linkage across products.
        .package(name: "Auth-Self", path: "."),
        .package(url: "https://github.com/ivalx1s/swift-ioc.git", from: "1.0.1"),
        .package(url: "https://github.com/ivalx1s/darwin-relux.git", from: "8.4.0"),
        .package(path: "../TestInfrastructure"),
    ],
    targets: [
        .target(
            name: "AuthModels",
            dependencies: []
        ),
        .target(
            name: "AuthReluxInt",
            dependencies: [
                .product(name: "AuthModels", package: "Auth-Self"),
                .product(name: "Relux", package: "darwin-relux"),
            ]
        ),
        .target(
            name: "AuthServiceInt",
            dependencies: [
                .product(name: "AuthModels", package: "Auth-Self"),
            ]
        ),
        .target(
            name: "AuthServiceImpl",
            dependencies: [
                .product(name: "AuthModels", package: "Auth-Self"),
                .product(name: "AuthServiceInt", package: "Auth-Self"),
            ]
        ),
        .target(
            name: "AuthReluxImpl",
            dependencies: [
                .product(name: "AuthModels", package: "Auth-Self"),
                .product(name: "AuthReluxInt", package: "Auth-Self"),
                .product(name: "AuthServiceInt", package: "Auth-Self"),
                .product(name: "SwiftIoC", package: "swift-ioc"),
                .product(name: "Relux", package: "darwin-relux"),
            ]
        ),
        .target(
            name: "AuthTestSupport",
            dependencies: [
                .product(name: "AuthModels", package: "Auth-Self"),
                .product(name: "AuthServiceInt", package: "Auth-Self"),
                .product(name: "AuthReluxInt", package: "Auth-Self"),
                .product(name: "Relux", package: "darwin-relux"),
                .product(name: "TestInfrastructure", package: "TestInfrastructure"),
            ]
        ),
        .testTarget(
            name: "AuthTests",
            dependencies: [
                "AuthReluxImpl",
                "AuthReluxInt",
                "AuthModels"
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

// Tests may depend on Impl targets.
let implAllowedTargets: Set<String> = [
    "AuthTests",
]

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

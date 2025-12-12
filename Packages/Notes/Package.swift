// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Notes",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "NotesModels", type: .dynamic, targets: ["NotesModels"]),
        .library(name: "NotesReluxInt", type: .dynamic, targets: ["NotesReluxInt"]),
        .library(name: "NotesServiceInt", type: .dynamic, targets: ["NotesServiceInt"]),
        .library(name: "NotesServiceImpl", type: .dynamic, targets: ["NotesServiceImpl"]),
        .library(name: "NotesReluxImpl", type: .dynamic, targets: ["NotesReluxImpl"]),
        .library(name: "NotesTestSupport", targets: ["NotesTestSupport"]),
    ],
    dependencies: [
        // Self-reference forces dynamic linkage across products.
        .package(name: "Notes-Self", path: "."),
        .package(url: "https://github.com/ivalx1s/swift-ioc.git", from: "1.0.1"),
        .package(url: "https://github.com/ivalx1s/swiftui-relux.git", from: "7.0.0"),
        .package(url: "https://github.com/ivalx1s/darwin-relux.git", from: "8.4.0"),
        .package(path: "../TestInfrastructure"),
    ],
    targets: [
        .target(
            name: "NotesModels",
            dependencies: []
        ),
        .target(
            name: "NotesReluxInt",
            dependencies: [
                .product(name: "NotesModels", package: "Notes-Self"),
                .product(name: "Relux", package: "darwin-relux"),
                .product(name: "SwiftUIRelux", package: "swiftui-relux"),
            ]
        ),
        .target(
            name: "NotesServiceInt",
            dependencies: [
                .product(name: "NotesModels", package: "Notes-Self"),
            ]
        ),
        .target(
            name: "NotesServiceImpl",
            dependencies: [
                .product(name: "NotesModels", package: "Notes-Self"),
                .product(name: "NotesServiceInt", package: "Notes-Self"),
            ]
        ),
        .target(
            name: "NotesReluxImpl",
            dependencies: [
                .product(name: "NotesModels", package: "Notes-Self"),
                .product(name: "NotesReluxInt", package: "Notes-Self"),
                .product(name: "NotesServiceInt", package: "Notes-Self"),
                .product(name: "SwiftIoC", package: "swift-ioc"),
                .product(name: "Relux", package: "darwin-relux"),
                .product(name: "SwiftUIRelux", package: "swiftui-relux"),
            ]
        ),
        .target(
            name: "NotesTestSupport",
            dependencies: [
                .product(name: "NotesModels", package: "Notes-Self"),
                .product(name: "NotesReluxInt", package: "Notes-Self"),
                .product(name: "NotesServiceInt", package: "Notes-Self"),
                .product(name: "Relux", package: "darwin-relux"),
                .product(name: "TestInfrastructure", package: "TestInfrastructure"),
            ]
        ),
        .testTarget(
            name: "NotesTests",
            dependencies: [
                "NotesReluxImpl",
                "NotesTestSupport",
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
    // PackageDescription.Dependency signatures change across SwiftPM versions.
    // Reflection keeps this guardrail resilient and prefers the "name" field.
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
    "NotesTests",
]

for t in package.targets {
    // Skip plugins/binaries themselves
    guard t.type != .plugin && t.type != .binary else { continue }

    let tName = t.name
    let deps = t.dependencies.map(depName)

    // 1) API may never depend on Impl (prevents vertical dependency chains)
    if isAPI(tName), deps.contains(where: isImpl) {
        preconditionFailure(
            "❌ \(tName) is an API target and must not depend on Impl targets. Found: \(deps.filter(isImpl))"
        )
    }

    // 2) UI may never depend on Impl (UI depends on API only)
    if isUI(tName), deps.contains(where: isImpl) {
        preconditionFailure(
            "❌ \(tName) is a UI target and must not depend on Impl targets. Found: \(deps.filter(isImpl))"
        )
    }

    // 3) Only composition-root targets (or tests) can depend on Impl at all
    if !implAllowedTargets.contains(tName), deps.contains(where: isImpl) {
        preconditionFailure(
            "❌ \(tName) depends on Impl targets, but only composition-root targets may do that. Found: \(deps.filter(isImpl))"
        )
    }
}

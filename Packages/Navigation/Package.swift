// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Navigation",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Lightweight — namespace only
        .library(name: "NavigationModels", type: .dynamic, targets: ["NavigationModels"]),

        // Interface — generic NavigationActions and protocols
        .library(name: "NavigationReluxInt", type: .dynamic, targets: ["NavigationReluxInt"]),

        // Implementation — generic Module and ModalRouter
        .library(name: "NavigationReluxImpl", type: .dynamic, targets: ["NavigationReluxImpl"]),

        // UI — generic NavLink, BackButton, ModalPresenter
        .library(name: "NavigationUI", type: .dynamic, targets: ["NavigationUI"]),
    ],
    dependencies: [
        // Self-reference forces dynamic linkage across products
        .package(name: "Navigation-Self", path: "."),
        .package(name: "darwin-relux", path: "../../../darwin-relux"),
        .package(name: "swiftui-relux", path: "../../../swiftui-relux"),
        .package(name: "swiftui-reluxrouter", path: "../../../swiftui-reluxrouter"),
    ],
    targets: [
        .target(
            name: "NavigationModels",
            dependencies: [],
            linkerSettings: [.linkedFramework("Foundation")]
        ),

        .target(
            name: "NavigationReluxInt",
            dependencies: [
                .product(name: "NavigationModels", package: "Navigation-Self"),
                .product(name: "Relux", package: "darwin-relux"),
            ],
            linkerSettings: [.linkedFramework("Foundation")]
        ),

        .target(
            name: "NavigationReluxImpl",
            dependencies: [
                .product(name: "NavigationModels", package: "Navigation-Self"),
                .product(name: "NavigationReluxInt", package: "Navigation-Self"),
                .product(name: "Relux", package: "darwin-relux"),
                .product(name: "SwiftUIRelux", package: "swiftui-relux"),
                .product(name: "ReluxRouter", package: "swiftui-reluxrouter"),
            ],
            linkerSettings: [.linkedFramework("Foundation")]
        ),

        .target(
            name: "NavigationUI",
            dependencies: [
                .product(name: "NavigationModels", package: "Navigation-Self"),
                .product(name: "NavigationReluxInt", package: "Navigation-Self"),
                .product(name: "NavigationReluxImpl", package: "Navigation-Self"),
                .product(name: "Relux", package: "darwin-relux"),
                .product(name: "SwiftUIRelux", package: "swiftui-relux"),
            ],
            linkerSettings: [.linkedFramework("Foundation")]
        ),
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

// NavigationUI is part of infra and may depend on impl for router state.
let uiAllowedImplTargets: Set<String> = [
    "NavigationUI",
]

// Navigation package has no app-level composition targets; allow infra UI as exception.
let implAllowedTargets: Set<String> = [
    "NavigationUI",
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

    if isUI(tName), deps.contains(where: isImpl), !uiAllowedImplTargets.contains(tName) {
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

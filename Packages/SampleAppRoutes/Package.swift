// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SampleAppRoutes",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SampleAppRoutes", type: .static, targets: ["SampleAppRoutes"]),
    ],
    dependencies: [
        .package(name: "SampleAppRoutes-Self", path: "."),
        .package(path: "../Auth"),
        .package(path: "../Notes"),
        .package(path: "../NotesUI"),
        .package(name: "darwin-relux", path: "../../../darwin-relux"),
        .package(name: "swiftui-reluxrouter", path: "../../../swiftui-reluxrouter"),
        .package(path: "../Navigation"),
    ],
    targets: [
        .target(
            name: "SampleAppRoutes",
            dependencies: [
                .product(name: "AuthReluxInt", package: "Auth"),
                .product(name: "NotesModels", package: "Notes"),
                .product(name: "NotesReluxInt", package: "Notes"),
                .product(name: "NotesUIAPI", package: "NotesUI"),
                .product(name: "NavigationReluxInt", package: "Navigation"),
                .product(name: "NavigationReluxImpl", package: "Navigation"),
                .product(name: "Relux", package: "darwin-relux"),
                .product(name: "ReluxRouter", package: "swiftui-reluxrouter"),
            ]
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
    if let s = findDepName(in: dep) { return s }
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

let implAllowedTargets: Set<String> = [
    "SampleAppRoutes",
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

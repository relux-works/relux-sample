// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Navigation",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Lightweight — Destination enum, ModalPage, namespace
        .library(name: "NavigationModels", type: .dynamic, targets: ["NavigationModels"]),

        // Interface — AppNavigation ActionProviding, protocols
        .library(name: "NavigationReluxInt", type: .dynamic, targets: ["NavigationReluxInt"]),

        // Implementation — Router, ModalRouter, Module (App target only)
        .library(name: "NavigationReluxImpl", type: .dynamic, targets: ["NavigationReluxImpl"]),

        // UI — NavigationLink, modifiers (Domain UI imports this)
        .library(name: "NavigationUI", type: .dynamic, targets: ["NavigationUI"]),
    ],
    dependencies: [
        // Self-reference forces dynamic linkage across products
        .package(name: "Navigation-Self", path: "."),
        .package(name: "darwin-relux", path: "../../../darwin-relux"),
        .package(name: "swiftui-relux", path: "../../../swiftui-relux"),
        .package(name: "swiftui-reluxrouter", path: "../../../swiftui-reluxrouter"),

        // Domain packages — for Page enums in Destination
        .package(path: "../Auth"),
        .package(path: "../Notes"),
        .package(path: "../NotesUI"),
    ],
    targets: [
        .target(
            name: "NavigationModels",
            dependencies: [
                .product(name: "Relux", package: "darwin-relux"),
                // Domain UI page enums
                .product(name: "AuthReluxInt", package: "Auth"),
                .product(name: "NotesModels", package: "Notes"),
                .product(name: "NotesReluxInt", package: "Notes"),
                .product(name: "NotesUIAPI", package: "NotesUI"),
            ],
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
                // Domain page types referenced by Destination
                .product(name: "AuthReluxInt", package: "Auth"),
                .product(name: "NotesModels", package: "Notes"),
                .product(name: "NotesReluxInt", package: "Notes"),
                .product(name: "NotesUIAPI", package: "NotesUI"),
            ],
            linkerSettings: [.linkedFramework("Foundation")]
        ),

        .target(
            name: "NavigationUI",
            dependencies: [
                .product(name: "NavigationModels", package: "Navigation-Self"),
                .product(name: "NavigationReluxInt", package: "Navigation-Self"),
                .product(name: "Relux", package: "darwin-relux"),
                .product(name: "SwiftUIRelux", package: "swiftui-relux"),
                .product(name: "NotesModels", package: "Notes"),
                .product(name: "NotesUIAPI", package: "NotesUI"),
            ],
            linkerSettings: [.linkedFramework("Foundation")]
        ),
    ]
)

// MARK: - Manifest-time API/Impl boundary guardrails

func depName(_ dep: Target.Dependency) -> String {
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

// Navigation package has no composition-root targets; tests (if added) can be listed here.
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

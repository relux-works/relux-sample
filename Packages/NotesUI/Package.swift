// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NotesUI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NotesUIAPI",
            type: .dynamic,
            targets: ["NotesUIAPI"]
        ),
        .library(
            name: "NotesUI",
            type: .dynamic,
            targets: ["NotesUI"]
        )
    ],
    dependencies: [
        .package(name: "NotesUI-Self", path: "."),
        .package(path: "../Notes"),
        .package(path: "../Navigation"),
        .package(path: "../SampleAppRoutes"),
        .package(name: "swiftui-relux", path: "../../../swiftui-relux"),
        .package(name: "darwin-relux", path: "../../../darwin-relux")
    ],
    targets: [
        .target(
            name: "NotesUIAPI",
            dependencies: [
                .product(name: "NotesModels", package: "Notes"),
                .product(name: "NotesReluxInt", package: "Notes"),
                .product(name: "Relux", package: "darwin-relux"),
            ]
        ),
        .target(
            name: "NotesUI",
            dependencies: [
                .product(name: "NotesUIAPI", package: "NotesUI-Self"),
                .product(name: "NotesModels", package: "Notes"),
                .product(name: "NotesReluxInt", package: "Notes"),
                .product(name: "NotesReluxImpl", package: "Notes"),
                .product(name: "NavigationModels", package: "Navigation"),
                .product(name: "NavigationReluxInt", package: "Navigation"),
                .product(name: "NavigationUI", package: "Navigation"),
                .product(name: "SampleAppRoutes", package: "SampleAppRoutes"),
                .product(name: "SwiftUIRelux", package: "swiftui-relux"),
                .product(name: "Relux", package: "darwin-relux")
            ],
            path: "Sources/NotesUI",
            linkerSettings: [.linkedFramework("Foundation")]
        )
    ]
)

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
                .product(name: "NotesServiceImpl", package: "Notes-Self"),
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

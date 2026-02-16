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
        .package(url: "https://github.com/relux-works/swift-ioc.git", from: "1.0.1"),
        .package(url: "https://github.com/relux-works/swift-relux.git", from: "8.4.0"),
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
                .product(name: "Relux", package: "swift-relux"),
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
                .product(name: "Relux", package: "swift-relux"),
            ]
        ),
        .target(
            name: "AuthTestSupport",
            dependencies: [
                .product(name: "AuthModels", package: "Auth-Self"),
                .product(name: "AuthServiceInt", package: "Auth-Self"),
                .product(name: "AuthReluxInt", package: "Auth-Self"),
                .product(name: "Relux", package: "swift-relux"),
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

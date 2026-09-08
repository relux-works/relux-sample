// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Auth",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AuthModels", targets: ["AuthModels"]),
        .library(name: "AuthReluxInt", targets: ["AuthReluxInt"]),
        .library(name: "AuthReluxImpl", targets: ["AuthReluxImpl"]),
        .library(name: "AuthServiceInt", targets: ["AuthServiceInt"]),
        .library(name: "AuthServiceImpl", targets: ["AuthServiceImpl"]),
        // Test-only helpers (static is fine)
        .library(name: "AuthTestSupport", targets: ["AuthTestSupport"]),
    ],
    dependencies: [
        .package(url: "https://github.com/relux-works/swift-ioc.git", exact: "1.0.3"),
        .package(url: "https://github.com/relux-works/swift-relux.git", exact: "9.2.0"),
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
                "AuthModels",
                .product(name: "Relux", package: "swift-relux"),
            ]
        ),
        .target(
            name: "AuthServiceInt",
            dependencies: [
                "AuthModels",
            ]
        ),
        .target(
            name: "AuthServiceImpl",
            dependencies: [
                "AuthModels",
                "AuthServiceInt",
            ]
        ),
        .target(
            name: "AuthReluxImpl",
            dependencies: [
                "AuthModels",
                "AuthReluxInt",
                "AuthServiceInt",
                .product(name: "SwiftIoC", package: "swift-ioc"),
                .product(name: "Relux", package: "swift-relux"),
            ]
        ),
        .target(
            name: "AuthTestSupport",
            dependencies: [
                "AuthModels",
                "AuthServiceInt",
                "AuthReluxInt",
                .product(name: "Relux", package: "swift-relux"),
                .product(name: "TestInfrastructure", package: "TestInfrastructure"),
            ]
        ),
        .testTarget(
            name: "AuthTests",
            dependencies: [
                "AuthServiceImpl",
                "AuthReluxImpl",
                "AuthReluxInt",
                "AuthModels",
                "AuthServiceInt",
                .product(name: "Relux", package: "swift-relux")
            ]
        )
    ]
)

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
    ],
    dependencies: [
        // Dev note: self-reference forces dynamic linkage across products.
        .package(name: "Auth-Self", path: "."),
        .package(url: "https://github.com/ivalx1s/swift-ioc.git", from: "1.0.1"),
        .package(url: "https://github.com/ivalx1s/darwin-relux.git", from: "8.4.0"),
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
                .product(name: "AuthServiceImpl", package: "Auth-Self"),
                .product(name: "SwiftIoC", package: "swift-ioc"),
                .product(name: "Relux", package: "darwin-relux"),
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

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Auth",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "Auth", targets: ["Auth"]),
        .library(name: "AuthImplementation", targets: ["AuthImplementation"])
    ],
    dependencies: [
        .package(url: "https://github.com/ivalx1s/swift-ioc.git", from: "1.0.1"),
        .package(url: "https://github.com/ivalx1s/darwin-relux.git", from: "8.4.0"),
    ],
    targets: [
        .target(
            name: "Auth",
            dependencies: [
                .product(name: "Relux", package: "darwin-relux"),
            ]
        ),
        .target(
            name: "AuthImplementation",
            dependencies: [
                "Auth",
                .product(name: "SwiftIoC", package: "swift-ioc"),
                .product(name: "Relux", package: "darwin-relux"),
            ]
        )
    ]
)

// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TestInfrastructure",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "TestInfrastructure", targets: ["TestInfrastructure"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ivalx1s/darwin-relux.git", from: "8.4.0"),
    ],
    targets: [
        .target(
            name: "TestInfrastructure",
            dependencies: [
                .product(name: "Relux", package: "darwin-relux"),
            ]
        )
    ]
)

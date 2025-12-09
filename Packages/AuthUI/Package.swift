// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AuthUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AuthUIAPI", targets: ["AuthUIAPI"]),
        .library(name: "AuthUI", targets: ["AuthUI"])
    ],
    dependencies: [
        .package(path: "../Auth"),
        .package(url: "https://github.com/ivalx1s/swiftui-relux.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "AuthUIAPI",
            dependencies: [
                .product(name: "AuthAPI", package: "Auth")
            ]
        ),
        .target(
            name: "AuthUI",
            dependencies: [
                "AuthUIAPI",
                .product(name: "AuthAPI", package: "Auth"),
                .product(name: "SwiftUIRelux", package: "swiftui-relux")
            ]
        )
    ]
)

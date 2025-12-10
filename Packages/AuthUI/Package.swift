// swift-tools-version: 6.0
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
        .package(name: "AuthUI-Self", path: "."),
        .package(path: "../Auth"),
        .package(url: "https://github.com/ivalx1s/swiftui-relux.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "AuthUIAPI",
            dependencies: [
                .product(name: "AuthModels", package: "Auth"),
                .product(name: "AuthReluxInt", package: "Auth")
            ]
        ),
        .target(
            name: "AuthUI",
            dependencies: [
                .product(name: "AuthUIAPI", package: "AuthUI-Self"),
                .product(name: "AuthReluxInt", package: "Auth"),
                .product(name: "SwiftUIRelux", package: "swiftui-relux")
            ]
        )
    ]
)

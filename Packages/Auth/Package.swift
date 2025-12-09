// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Auth",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Auth",
            type: .dynamic,
            targets: ["Auth"]
        ),
        .library(
            name: "AuthImplementation",
            type: .dynamic,
            targets: ["AuthImplementation"]
        ),
        .library(
            name: "AuthServiceInterface",
            type: .dynamic,
            targets: ["AuthServiceInterface"]
        ),
        .library(
            name: "AuthServiceImplementation",
            type: .dynamic,
            targets: ["AuthServiceImplementation"]
        )
    ],
    dependencies: [
        // Dev note (markdown-ish for readability):
        // - Goal: keep the interface (Auth) explicitly dynamic; impl may be
        //   dynamic or static (dynamic preferred early).
        // - Problem: with two dynamic products where one depends on another,
        //   Xcode/SPM currently still tris to link target deps statically, ignoring product
        //   linkage, so builds fail.
        // - Solution: declare a self package and depend on the Auth product to
        //   force dynamic linkage; works for dynamic/dynamic and dynamic
        //   interface + static impl.
        // - Alternative: split interface/impl into separate packages; adds
        //   boilerplate, is error-prone, and still needs duplicated interface
        //   deps in impl and in Xcode.
        .package(name: "Auth-Self", path: "."),
        .package(url: "https://github.com/ivalx1s/swift-ioc.git", from: "1.0.1"),
        .package(url: "https://github.com/ivalx1s/darwin-relux.git", from: "8.4.0"),
    ],
    targets: [
        .target(
            name: "AuthServiceInterface",
            dependencies: [
                .product(name: "Auth", package: "Auth-Self"),
            ]
        ),
        .target(
            name: "AuthServiceImplementation",
            dependencies: [
                .product(name: "Auth", package: "Auth-Self"),
                .product(name: "AuthServiceInterface", package: "Auth-Self"),
            ]
        ),
        .target(
            name: "Auth",
            dependencies: [
                .product(name: "Relux", package: "darwin-relux"),
            ]
        ),
        .target(
            name: "AuthImplementation",
            dependencies: [
                .product(name: "Auth", package: "Auth-Self"),
                .product(name: "AuthServiceInterface", package: "Auth-Self"),
                .product(name: "AuthServiceImplementation", package: "Auth-Self"),
                .product(name: "SwiftIoC", package: "swift-ioc"),
                .product(name: "Relux", package: "darwin-relux"),
            ]
        ),
        .testTarget(
            name: "AuthTests",
            dependencies: [
                "AuthImplementation",
                "Auth"
            ]
        )
    ]
)

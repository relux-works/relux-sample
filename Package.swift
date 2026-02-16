// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "swift-httpclient",
    platforms: [
        .iOS(.v15),
        .watchOS(.v8),
        .macOS(.v12),
        .tvOS(.v15),
    ],
    products: [
        .library(
            name: "HttpClient",
            targets: ["HttpClient"]
        ),
        // Test-only helpers (static by default)
        .library(
            name: "HttpClientTestSupport",
            targets: ["HttpClientTestSupport"]
        ),
    ],
    targets: [
        .target(
            name: "HttpClient",
            dependencies: [],
            path: "Sources"
        ),
        .target(
            name: "HttpClientTestSupport",
            dependencies: ["HttpClient"],
            path: "TestsSupport"
        )
    ]
)

// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KinescopeSDK",
    defaultLocalization: "en",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "KinescopeSDK",
            type: .dynamic,
            targets: ["KinescopeSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/M3U8Kit/M3U8Parser.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "KinescopeSDK",
            dependencies: [
                .product(name: "M3U8Parser", package: "M3U8Parser"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf")
            ],
            path: "Sources/KinescopeSDK"),
        .testTarget(
            name: "KinescopeSDKTests",
            dependencies: [
                "KinescopeSDK"
            ],
            path: "Sources/KinescopeSDKTests")
    ]
)

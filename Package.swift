// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KinescopeSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "KinescopeSDK",
            type: .dynamic,
            targets: ["KinescopeSDK"]),
        // Player plus the vertical feed in one framework. An app adds one product:
        // KinescopeSDK for the player only, or KinescopeShorts for Shorts (the player comes with it).
        // Adding both links the player twice.
        .library(
            name: "KinescopeShorts",
            type: .dynamic,
            targets: ["KinescopeSDK", "KinescopeShorts"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // 1.2.0 renamed the package and product to M3U8Kit, so stay on the 1.1.x line that ships M3U8Parser.
        .package(url: "https://github.com/M3U8Kit/M3U8Parser.git", "1.1.0"..<"1.2.0"),
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
            path: "Sources/KinescopeSDK",
            // Not part of the Swift package: the plist is for the Xcode framework project, the protos are the source of events.pb.swift.
            exclude: [
                "Info.plist",
                "Models/Events/events.proto",
                "Models/Events/gogo.proto"
            ],
            resources: [
                .process("Resources/Fonts"),
                .process("Resources/Assets.xcassets"),
                .process("Resources/en.lproj"),
                .process("Resources/ru.lproj")
            ]),
        .target(
            name: "KinescopeShorts",
            dependencies: ["KinescopeSDK"],
            path: "Sources/KinescopeShorts",
            resources: [
                .process("Resources/Assets.xcassets")
            ]),
        .testTarget(
            name: "KinescopeSDKTests",
            dependencies: [
                "KinescopeSDK"
            ],
            path: "Sources/KinescopeSDKTests")
    ]
)

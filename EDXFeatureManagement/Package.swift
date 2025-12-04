// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EDXFeatureManagement",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "EDXFeatureManagement",
            targets: ["EDXFeatureManagement"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.57.0"),
        .package(url: "https://github.com/optimizely/swift-sdk.git", from: "5.1.0")
    ],
    targets: [
        .target(
            name: "EDXFeatureManagement",
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "EDXFeatureManagementTests",
            dependencies: ["EDXFeatureManagement"]
        )
    ]
)

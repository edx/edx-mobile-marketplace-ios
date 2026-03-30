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
        .package(url: "https://github.com/Datadog/dd-sdk-ios.git", exact: "3.7.0")
    ],
    targets: [
        .target(
            name: "EDXFeatureManagement",
            dependencies: [
                .product(name: "DatadogCore", package: "dd-sdk-ios"),
                .product(name: "DatadogLogs", package: "dd-sdk-ios"),
                .product(name: "DatadogRUM", package: "dd-sdk-ios"),
                .product(name: "DatadogWebViewTracking", package: "dd-sdk-ios"),
                .product(name: "DatadogCrashReporting", package: "dd-sdk-ios")
            ],
            linkerSettings: [.linkedFramework("WebKit")],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins"),
            ]
        ),
        .testTarget(
            name: "EDXFeatureManagementTests",
            dependencies: ["EDXFeatureManagement"]
        )
    ]
)

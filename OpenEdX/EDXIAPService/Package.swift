// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EDXIAPService",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EDXIAPService",
            targets: ["EDXIAPService"])
    ],
    dependencies: [
        .package(url: "https://github.com/rnr/openedx-app-foundation-ios", branch: "anton/plugins-experiments"),
        .package(url: "https://github.com/bizz84/SwiftyStoreKit.git", from: .init(stringLiteral: "0.16.4"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EDXIAPService",
            dependencies: [
                .product(name: "OEXFoundation", package: "openedx-app-foundation-ios"),
                .product(name: "SwiftyStoreKit", package: "SwiftyStoreKit")
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("fonts_file.ttf")
            ]
        ),
        .testTarget(
            name: "EDXIAPServiceTests",
            dependencies: ["EDXIAPService"]
        )
    ]
)

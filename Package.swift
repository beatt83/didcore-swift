// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "didcore-swift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DIDCore",
            targets: ["DIDCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-libp2p/swift-multibase.git", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/swift-libp2p/swift-bases.git", .upToNextMajor(from: "0.0.3"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DIDCore",
            dependencies: [
                .product(name: "Multibase", package: "swift-multibase"),
                .product(name:  "BaseX", package: "swift-bases"),
                .product(name:  "Base64", package: "swift-bases")
            ]
        ),
        .testTarget(
            name: "DIDCoreTests",
            dependencies: ["DIDCore"]),
    ]
)

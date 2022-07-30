// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SImages",
    platforms: [
           .iOS(.v13),
           .macOS(.v10_15),
           .watchOS(.v6)
       ],
    products: [
        .library(
            name: "SImages",
            targets: ["SImages"]),
    ],
    dependencies: [
        .package(url: "https://github.com/NoeOnJupiter/STools", "1.0.0"..<"2.0.0")
    ],
    targets: [
        .target(
            name: "SImages",
            dependencies: [
                .product(name: "STools", package: "STools")
            ]),
        .testTarget(
            name: "SImagesTests",
            dependencies: ["SImages"]),
    ]
)

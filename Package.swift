// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "MediaUI",
    platforms: [
           .iOS(.v13),
           .macOS(.v12),
           .watchOS(.v6)
       ],
    products: [
        .library(
            name: "MediaUI",
            targets: ["MediaUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/TimmysApp/STools", "1.0.81"..<"2.0.0")
    ],
    targets: [
        .target(
            name: "MediaUI",
            dependencies: [
                .product(name: "STools", package: "STools")
            ]),
    ]
)


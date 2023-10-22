// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "MediaUI",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "MediaUI", targets: ["MediaUI"])
    ],
    targets: [
        .target(name: "MediaUI")
    ]
)


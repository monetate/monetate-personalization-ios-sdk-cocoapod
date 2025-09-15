// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Monetate",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "Monetate", targets: ["Monetate"])
    ],
    targets: [
        .target(name: "Monetate", path: "monetate")
    ],
    swiftLanguageVersions: [
        .version("5")
    ]
)

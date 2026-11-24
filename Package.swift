// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "monetate-ios-sdk",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Monetate",
            targets: ["Monetate"]
        )
    ],
    targets: [
        .target(
            name: "Monetate",
            dependencies: [],
            path: "Sources/monetate"
        ),
        .testTarget(
                name: "MonetateTests",
                dependencies: ["Monetate"],
                path: "Tests/monetateTests",
                resources: [.process("support")]
            )
    ]
)

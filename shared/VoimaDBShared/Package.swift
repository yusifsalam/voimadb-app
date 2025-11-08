// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VoimaDBShared",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "VoimaDBShared",
            targets: ["VoimaDBShared"]
        ),
    ],
    dependencies: [
        // No external dependencies - pure Swift
    ],
    targets: [
        .target(
            name: "VoimaDBShared",
            dependencies: [],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "VoimaDBSharedTests",
            dependencies: ["VoimaDBShared"],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("ExistentialAny"),
    ]
}

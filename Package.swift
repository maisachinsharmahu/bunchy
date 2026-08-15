// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Bunchy",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Bunchy",
            path: "Sources/Bunchy"
        )
    ]
)

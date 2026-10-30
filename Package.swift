// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Caffeguard",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(
            name: "Caffeguard",
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(
            name: "CaffeguardTests",
            dependencies: ["Caffeguard"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
    ]
)

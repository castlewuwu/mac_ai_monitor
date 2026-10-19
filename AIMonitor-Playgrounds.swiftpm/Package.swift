// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AI Monitor",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .executable(name: "AI Monitor", targets: ["AIMonitorUI"])
    ],
    targets: [
        .executableTarget(
            name: "AIMonitorUI",
            path: "Sources/AIMonitorUI"
        )
    ]
)
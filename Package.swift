// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Oqto",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Oqto", targets: ["Oqto"])
    ],
    targets: [
        .target(name: "Oqto"),
        .testTarget(name: "OqtoTests", dependencies: ["Oqto"])
    ]
)
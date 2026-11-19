// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "NWWhatsNewKit",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [.library(name: "NWWhatsNewKit", targets: ["NWWhatsNewKit"])],
    dependencies: [
        .package(url: "https://github.com/nitricware/NWVersionKit.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "NWWhatsNewKit",
            dependencies: [.product(name: "NWVersionKit", package: "NWVersionKit")]
        ),
        .testTarget(
            name: "NWWhatsNewKitTests",
            dependencies: ["NWWhatsNewKit"]
        ),
    ]
)

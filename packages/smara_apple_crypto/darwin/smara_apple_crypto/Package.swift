// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "smara_apple_crypto",
    platforms: [
        .iOS("15.0"),
        .macOS("12.0"),
    ],
    products: [
        .library(name: "smara-apple-crypto", targets: ["smara_apple_crypto"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "smara_apple_crypto",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ],
            linkerSettings: [
                .linkedFramework("CryptoKit"),
                .linkedFramework("Network"),
                .linkedFramework("Security"),
            ]
        )
    ]
)

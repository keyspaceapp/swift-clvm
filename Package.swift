// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-clvm",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "CLVM",
            targets: ["CLVM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/dankogai/swift-bignum", from: "5.2.5"),
        .package(url: "https://github.com/jverkoey/BinaryCodable", from: "0.3.1"),
        .package(url: "https://github.com/keyspaceapp/swift-bls-signatures", from: "0.0.3")
    ],
    targets: [
        .target(
            name: "CLVM",
            dependencies: [
                .product(name: "BigNum", package: "swift-bignum", condition: nil),
                .product(name: "BinaryCodable", package: "BinaryCodable", condition: nil),
                .product(name: "BLS", package: "swift-bls-signatures", condition: nil)
            ]),
        .testTarget(
            name: "CLVMTests",
            dependencies: ["CLVM"]
        )
    ]
)

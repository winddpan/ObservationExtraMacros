// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "ObservationExtraMacros",
    platforms: [
        .macOS(.v14), .iOS(.v17), .tvOS(.v17), .watchOS(.v10),
        .macCatalyst(.v17),
    ],
    products: [
        .executable(
            name: "ObservationExtraMacrosClient",
            targets: ["ObservationExtraMacrosClient"]
        ),
        .library(
            name: "ObservationUserDefaults",
            targets: ["ObservationUserDefaults"]
        ),
        .library(
            name: "ObservationQuery",
            targets: ["ObservationQuery"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0")
    ],
    targets: [
        // Tests all in one
        .testTarget(
            name: "ObservationExtraMacrosTests",
            dependencies: [
                "ObservationUserDefaults",
                "ObservationQuery",
                .product(
                    name: "SwiftSyntaxMacrosTestSupport",
                    package: "swift-syntax"),
            ],
            path: "Tests"
        ),
        .executableTarget(
            name: "ObservationExtraMacrosClient",
            dependencies: [
                "ObservationUserDefaults",
                "ObservationQuery",
            ]
        ),

        // ObservationUserDefaults
        .target(
            name: "ObservationUserDefaults",
            dependencies: ["ObservationUserDefaultsMacros"]
        ),
        .macro(
            name: "ObservationUserDefaultsMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        // ObservationQuery
        .target(
            name: "ObservationQuery",
            dependencies: ["ObservationQueryMacros"]
        ),
        .macro(
            name: "ObservationQueryMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

    ]
)

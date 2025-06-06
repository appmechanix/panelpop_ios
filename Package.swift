// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PanelPop",
    platforms: [
        .iOS(.v15),
        .macOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PanelPop",
            targets: ["PanelPop"]),
    ],
    dependencies: [
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PanelPop",
            dependencies: [
  
            ]),
        .testTarget(
            name: "PanelPopTests",
            dependencies: ["PanelPop"]
        ),
    ]
)

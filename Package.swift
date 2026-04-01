// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftDown",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
  ],
  products: [
    .library(
      name: "SwiftDown",
      targets: ["SwiftDown"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/swiftlang/swift-markdown.git",
      branch: "main"
    ),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.0.0")),
  ],
  targets: [
    .target(
      name: "SwiftDown",
      dependencies: [
        .product(name: "Markdown", package: "swift-markdown")
      ],
      exclude: ["../../SwiftDownDemo"],
      resources: [.copy("Resources/Themes")]
    ),
    .testTarget(
      name: "SwiftDownTests",
      dependencies: ["SwiftDown", "Nimble"]
    )
  ]
)

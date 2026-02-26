// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Toolbox",
    platforms: [ .iOS(.v17) ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Toolbox",
            targets: ["Toolbox"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", branch: "main"),
        .package(url: "https://github.com/SnapKit/SnapKit", branch: "main"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.10.2"),
        .package(url: "https://github.com/Alamofire/Alamofire", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Toolbox",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift", condition: nil),
                .product(name: "RxCocoa", package: "RxSwift", condition: nil),
                .product(name: "SnapKit", package: "SnapKit", condition: nil),
                .product(name: "Kingfisher", package: "Kingfisher", condition: nil),
                .product(name: "Alamofire", package: "Alamofire", condition: nil),
            ],
            swiftSettings: [
                // This flag effectively reverts strict checking to a minimal level
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=targeted"])
            ]
        )
    ]
)


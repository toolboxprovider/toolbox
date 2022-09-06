// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Toolbox",
    platforms: [ .iOS(.v13) ],
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
                .productItem(name: "RxSwift", package: "RxSwift", condition: nil),
                .productItem(name: "RxCocoa", package: "RxSwift", condition: nil),
                .productItem(name: "SnapKit", package: "SnapKit", condition: nil),
                .productItem(name: "Kingfisher", package: "Kingfisher", condition: nil),
                .productItem(name: "Alamofire", package: "Alamofire", condition: nil),
            ]
        )
    ]
)

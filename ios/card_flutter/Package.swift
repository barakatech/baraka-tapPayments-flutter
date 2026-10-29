// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "card_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "card-flutter", targets: ["card_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Keep in sync with the TapPayments-Card-iOS pod tag in the app's Podfile.
        .package(url: "https://github.com/barakatech/baraka-tapPayments-ios.git", exact: "1.0.14")
    ],
    targets: [
        .target(
            name: "card_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Card-iOS", package: "baraka-tapPayments-ios")
            ]
        )
    ]
)

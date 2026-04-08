// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "JAPinView",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "JAPinView",
            targets: ["JAPinView"]
        )
    ],
    targets: [
        .target(
            name: "JAPinView"
        )
    ]
)

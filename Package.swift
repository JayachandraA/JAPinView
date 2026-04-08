//
//  Package.swift
//  JAPinView
//
//  Created by Jayachandra Agraharam on 01/04/26.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

// swift-tools-version: 5.9
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
            name: "JAPinView",
            path: "Sources/JAPinView"
        )
    ]
)

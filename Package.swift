// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileDownloadingCenter",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "FileDownloadingCenter",
            targets: ["FileDownloadingCenter"]),
        
    ],
    dependencies: [
        .package(url: "https://github.com/ashleymills/Reachability.swift.git", .exact("5.0.0"))
    ],
    targets: [
        .target(
            name: "FileDownloadingCenter",
            dependencies: ["Reachability"],
            path: "FileDownloadingCenter"),
        .testTarget(
            name: "FileDownloadingCenter_Tests",
            dependencies: ["FileDownloadingCenter"]),
    ]
)

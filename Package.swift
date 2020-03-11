// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileDownloadingCenter",
    platforms: [
        .iOS(.v10),
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "FileDownloadingCenter",
            targets: ["FileDownloadingCenter"]),
        
    ],
    targets: [
        .target(
            name: "FileDownloadingCenter",
            dependencies: ["Reachability"],
            path: "FileDownloadingCenter")
    ]
)

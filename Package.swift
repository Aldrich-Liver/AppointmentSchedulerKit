// AppointmentSchedulerSDK/Package.swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppointmentSchedulerSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AppointmentSchedulerSDK",
            targets: ["AppointmentSchedulerSDK"]
        )
    ],
    targets: [
        .target(
            name: "AppointmentSchedulerSDK",
            path: "Sources/AppointmentSchedulerSDK"
        )
    ]
)

// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "AppointmentSchedulerKit",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(name: "AppointmentSchedulerKit", targets: ["AppointmentSchedulerKit"])
  ],
  targets: [
    .target(
      name: "AppointmentSchedulerKit",
      dependencies: [],
      path: "Sources/AppointmentSchedulerKit",
      resources: [
        // Si usara Localizable.strings / imágenes:
        // .process("Resources")
      ]
    )
  ]
)

// swift-tools-version: 5.9
// Models, API requests and helpers shared by the app, widget and watch app.
import PackageDescription

let package = Package(
    name: "HaltestellenmonitorKit",
    platforms: [.iOS(.v17), .watchOS(.v10)],
    products: [
        .library(name: "HaltestellenmonitorKit", targets: ["HaltestellenmonitorKit"])
    ],
    targets: [
        .target(name: "HaltestellenmonitorKit", resources: [.copy("Resources/stops.json")])
    ]
)

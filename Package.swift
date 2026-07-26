// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "ClaySwift",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "ClaySwift", targets: ["ClaySwift"]),
        .executable(name: "BasicUI", targets: ["BasicUI"]),
    ],
    targets: [
        .target(
            name: "CClay",
            path: "Sources/CClay",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("."),
            ]
        ),
        .target(
            name: "CSDL3",
            dependencies: ["CClay"],
            path: "Sources/CSDL3",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("."),
                .unsafeFlags([
                    "-I/usr/local/include",
                    "-I/opt/homebrew/include",
                    "-I/usr/include",
                ]),
            ],
            linkerSettings: [
                .linkedLibrary("SDL3"),
                .linkedLibrary("SDL3_ttf"),
                .linkedLibrary("SDL3_image"),
                .unsafeFlags([
                    "-L/usr/local/lib",
                    "-L/opt/homebrew/lib",
                ]),
            ]
        ),
        .target(
            name: "ClaySwift",
            dependencies: ["CClay", "CSDL3"],
            swiftSettings: [
                .unsafeFlags([
                    "-I/usr/local/include",
                    "-I/opt/homebrew/include",
                ]),
            ]
        ),
        .testTarget(
            name: "ClaySwiftTests",
            dependencies: ["ClaySwift"]
        ),
        .executableTarget(
            name: "BasicUI",
            dependencies: ["ClaySwift"],
            path: "Examples/BasicUI"
        ),
    ]
)

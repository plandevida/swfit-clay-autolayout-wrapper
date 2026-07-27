// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "ClaySwift",
    products: [
        .library(name: "ClaySwift", targets: ["ClaySwift"]),
        .executable(name: "BasicUI", targets: ["BasicUI"]),
        .executable(name: "BasicSwiftUI", targets: ["BasicSwiftUI"]),
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
        .systemLibrary(
            name: "CSDLSupport",
            pkgConfig: "sdl3 sdl3-ttf sdl3-image",
            providers: [
                .brew(["sdl3", "sdl3_ttf", "sdl3_image"]),
            ]
        ),
        .target(
            name: "CSDL3",
            dependencies: ["CClay", "CSDLSupport"],
            path: "Sources/CSDL3",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("."),
            ],
            linkerSettings: [
                .linkedLibrary("SDL3"),
                .linkedLibrary("SDL3_ttf"),
                .linkedLibrary("SDL3_image"),
            ]
        ),
        .target(
            name: "ClaySwift",
            dependencies: ["CClay", "CSDL3"]
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
        .executableTarget(
            name: "BasicSwiftUI",
            path: "Examples/BasicSwiftUI"
        ),
    ]
)

#if os(macOS)
    package.platforms = [.macOS("13")]
#endif

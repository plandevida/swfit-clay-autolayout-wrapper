# ClaySwift

A Swift wrapper around the [Clay](https://github.com/nicbarker/clay) immediate-mode layout engine, with a SwiftUI-inspired declarative API and a hardware-accelerated SDL3 renderer.

ClaySwift lets you describe a UI as a tree of views, lays it out with Clay, and renders it through SDL3 — including rounded rectangles, borders, clipped scroll views, images, and UTF-8 text via SDL3_ttf.

```swift
WindowGroup("ClaySwift Counter", width: 800, height: 600) {
    VStack(alignment: .init(x: .center, y: .center), spacing: 16) {
        Text("Clicked \(count) times")
            .font(.system(size: 32))
        Button("Increment") {
            self.count += 1
        }
        .frame(width: 200, height: 50)
    }
    .padding(24)
    .background(ClayColor(245, 245, 250))
    .cornerRadius(12)
}
```

> **Status:** early-stage / experimental. The API is usable and covered by tests, but may change between releases.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Running the Examples](#running-the-examples)
- [How It Works](#how-it-works)
- [API Overview](#api-overview)
  - [App and Scenes](#app-and-scenes)
  - [Views](#views)
  - [Modifiers](#modifiers)
  - [State](#state)
  - [Styling Types](#styling-types)
  - [Fonts](#fonts)
  - [Input](#input)
  - [Low-Level API](#low-level-api)
- [Low-Level Example](#low-level-example)
- [Project Structure](#project-structure)
- [Testing](#testing)
- [Platform Support and Limitations](#platform-support-and-limitations)
- [Contributing](#contributing)
- [Acknowledgements](#acknowledgements)

## Features

- **Declarative, SwiftUI-style API** — `VStack`, `HStack`, `Text`, `Button`, `ForEach`, `ScrollView`, modifiers, and `@State`.
- **Result-builder DSL** — `@ClayViewBuilder` supports conditionals, loops, and optional content.
- **Clay-powered layout** — flexbox-like sizing, padding, gaps, alignment, floating elements, clipping, and aspect ratios.
- **SDL3 rendering** — rounded rectangles, borders, scissor clipping, images, and text with SDL3_ttf.
- **Automatic font handling** — system fonts are discovered per platform and registered on demand.
- **Retained state across frames** — `@State` values survive the immediate-mode rebuild loop.
- **Input plumbing** — mouse position/buttons, scroll wheel, and keyboard state are fed to Clay automatically.
- **Swift 6 concurrency** — app, scene, window, context, and state APIs are `@MainActor` isolated.
- **Vendored Clay** — Clay 0.14 is included, so no separate Clay dependency is required.

## Requirements

- **Swift 6.0+** (the package uses `swift-tools-version: 6.0`).
- **macOS 13+** for the declared macOS platform.
- **SDL3**, **SDL3_ttf**, and **SDL3_image** installed and discoverable by `pkg-config`.
- **pkg-config** itself (used by the `CSDLSupport` system-library target).

### Install SDL3 dependencies

**macOS (Homebrew):**

```sh
brew install sdl3 sdl3_ttf sdl3_image
```

**Ubuntu / Debian:**

```sh
sudo apt install pkg-config libsdl3-dev libsdl3-ttf-dev libsdl3-image-dev
```

**Windows (vcpkg):**

```powershell
vcpkg install sdl3[sdl3-ttf,sdl3-image]
```

Make sure the SDL3 `.pc` files are on your `PKG_CONFIG_PATH`.

## Installation

ClaySwift is a Swift Package. Add it as a local package dependency:

```swift
// Package.swift
dependencies: [
    .package(path: "../swift-clay-wrapper")
],
targets: [
    .executableTarget(
        name: "MyApp",
        dependencies: [
            .product(name: "ClaySwift", package: "swift-clay-wrapper")
        ]
    )
]
```

If you publish or host the repository remotely, replace `.package(path:)` with `.package(url: "...", from: "...")`.

The `ClaySwift` product links SDL3, SDL3_ttf, and SDL3_image automatically through the `CSDL3` / `CSDLSupport` targets.

## Quick Start

Create an executable target and define an app by conforming to `ClayApp`:

```swift
import ClaySwift

@main
final class CounterApp: ClayApp {
    @State private var count = 0

    required init() {}

    var body: some ClayScene {
        WindowGroup("ClaySwift Counter", width: 800, height: 600) {
            VStack(alignment: .init(x: .center, y: .center), spacing: 16) {
                Text("Clicked \(count) times")
                    .font(.system(size: 32))

                Button("Increment") {
                    self.count += 1
                }
                .frame(width: 200, height: 50)
            }
            .padding(24)
            .background(ClayColor(245, 245, 250))
            .cornerRadius(12)
        }
    }
}
```

Build and run:

```sh
swift run MyApp
```

`ClayApp` provides a default `main()`. It creates a `ClayWindow`, enters the SDL3 event/render loop, and rebuilds `body` every frame.

## Running the Examples

The package ships with three executables:

```sh
swift run BasicClayUI   # Compact ClaySwift demo
swift run BasicUI       # Larger demo with scrolling, cards, and state
swift run BasicSwiftUI  # Native SwiftUI reference UI (does not use ClaySwift)
```

| Target | Description |
| --- | --- |
| `BasicClayUI` | Small ClaySwift app showing stacks, text, buttons, and state. |
| `BasicUI` | Richer ClaySwift layout with a sidebar, scroll view, `ForEach`, and styling. |
| `BasicSwiftUI` | A pure SwiftUI implementation of a similar UI, useful as a visual reference. |

## How It Works

1. `ClayAppRuntime` evaluates your `ClayApp.body` each frame.
2. Views translate themselves into Clay element declarations (`ClayElement`, `ClayText`, etc.).
3. Clay computes layout and produces a `Clay_RenderCommandArray`.
4. The bundled C renderer (`clay_renderer_SDL3.c`) draws those commands with SDL3 and SDL3_ttf.
5. `ClayWindow` presents the frame and frees temporary string buffers.

Because this is an immediate-mode UI, `body` is re-evaluated continuously. `@State` gives you values that persist between evaluations.

## API Overview

### App and Scenes

```swift
public protocol ClayApp {
    associatedtype Body: ClayScene
    init()
    @ClaySceneBuilder var body: Self.Body { get }
}
```

A scene describes a top-level window:

```swift
WindowGroup("My App", width: 1200, height: 800) {
    // views
}
```

`ClaySceneBuilder` currently supports a single scene expression. `WindowGroup` is the scene type understood by the runtime.

### Views

| View | Description |
| --- | --- |
| `Text(_:)` | Renders a text string. Use `.font(_:)` and `.textAlignment(_:)` for styling. |
| `Button(_:action:)` | A clickable, styled button with a text label. |
| `VStack(alignment:spacing:content:)` | Vertical stack. |
| `HStack(alignment:spacing:content:)` | Horizontal stack. |
| `ScrollView(_:content:)` | Clipped scroll container; supports `.vertical`, `.horizontal`, or `.all`. |
| `ForEach` | Repeats content over a `Range<Int>` or `Collection`. |
| `EmptyView` | Renders nothing. |

`@ClayViewBuilder` supports multiple statements, `if`/`else`, optional views, `for` loops, and arrays of views.

```swift
VStack(spacing: 8) {
    ForEach(items, id: \.self) { item, _ in
        Text(item)
    }

    if showFooter {
        Text("Footer")
    }
}
```

> `ForEach` closures receive `(element, index)` for collections, and just `index` for `Range<Int>`.

### Modifiers

Modifiers are available on any `ClayView`:

| Modifier | Description |
| --- | --- |
| `.padding(_:)` | Uniform padding. |
| `.padding(_ edges: ClayEdge, _:)` | Per-edge padding using `.leading`, `.trailing`, `.top`, `.bottom`, `.horizontal`, `.vertical`, or `.all`. |
| `.frame(width:height:maxWidth:maxHeight:alignment:)` | Fixed or maximum dimensions with child alignment. |
| `.background(_ color:)` | Background color. |
| `.cornerRadius(_:)` | Rounded corners. |
| `.border(_ width:color:)` | Border width and color. |
| `.font(_:)` | Text font selection (the `Text`-specific overload). |
| `.foregroundStyle(_:)` | Currently a pass-through; see [limitations](#platform-support-and-limitations). |

```swift
Text("Hello")
    .font(.system(size: 24))
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .frame(maxWidth: .infinity, alignment: .init(x: .left, y: .center))
    .background(ClayColor(250, 250, 255))
    .cornerRadius(6)
    .border(1, color: ClayColor(200, 200, 210))
```

### State

`@State` is backed by `ClayAppRuntime`, so values persist across frames:

```swift
@State private var count = 0

Button("Increment") {
    self.count += 1
}
```

A binding is available through the projected value (`$count`):

```swift
Text("Value: \($count.wrappedValue)")
```

> State is intended for use inside a `ClayApp` while its runtime is active. Use a `class` for your app type so mutation from closures works naturally.

### Styling Types

| Type | Purpose |
| --- | --- |
| `ClayColor` | RGBA color with `UInt8` or `Float` initializers and common presets. |
| `ClayPadding` | Per-side padding. |
| `ClayCornerRadius` | Per-corner radii. |
| `ClaySizing` / `ClaySizingAxis` | `.fit`, `.grow(max:)`, `.fixed(_:)`, `.percent(_:)`. |
| `ClayChildAlignment` | Horizontal (`left`/`center`/`right`) and vertical (`top`/`center`/`bottom`) alignment. |
| `ClayLayoutConfig` | Sizing, padding, gap, alignment, and layout direction. |
| `ClayTextConfig` | Color, font ID, size, letter spacing, line height, wrapping, and alignment. |
| `ClayBorderConfig` / `ClayBorderWidth` | Border widths, color, and radius. |
| `ClayFloatingConfig` | Offsets, z-index, attach points, pointer capture, and clipping. |
| `ClayClipConfig` | Horizontal/vertical clipping and child offset. |
| `ClayAspectRatioConfig` | Aspect-ratio constraint. |
| `ClayID` | String/index-based Clay element identifier. |

### Fonts

- `Text(...).font(.system(size:))` resolves a system font automatically.
- System fonts are discovered by `findSystemFont()`:
  - macOS: Helvetica
  - Linux: DejaVu Sans / Liberation Sans
  - Windows: Arial / Times New Roman
- `ClayAppRuntime` registers `ClayFont-16` and `ClayFont-24` at startup; other sizes are registered on demand.
- Custom fonts can be selected per view:

```swift
Text("Hello")
    .font(.custom(name: "Inter", path: "/path/to/Inter-Regular.ttf", size: 18))
```

For direct registry access, use `ClayFontRegistry`:

```swift
let registry = ClayFontRegistry()
let id = try registry.register(name: "Body", path: "/path/to/font.ttf", size: 16)
let font = registry.font(byId: id)
```

### Input

`SDLInputState` exposes the current frame's input:

```swift
public struct SDLInputState {
    public var mouseX: Float
    public var mouseY: Float
    public var mouseLeftDown: Bool
    public var mouseLeftPressed: Bool
    public var mouseLeftReleased: Bool
    public var scrollX: Float
    public var scrollY: Float
    public var keysDown: Set<UInt32>
    public var keysPressed: Set<UInt32>
    public var keysReleased: Set<UInt32>
}
```

The window feeds pointer and scroll state into Clay automatically, and `Button` uses pointer hit-testing to detect clicks.

### Low-Level API

The high-level view API is optional. You can use the Clay bridge directly:

- `ClayContext` — owns the Clay arena, sets layout dimensions, begins/ends layout, exposes pointer hit-testing, debug mode, and element data.
- `ClayWindow` — SDL3 window, renderer, text engine, event loop, and frame timing.
- `ClayElement`, `ClayText`, `ClayRectangle`, `ClayBorderElement`, `ClayImageElement` — element declarations conforming to `ClayElementProtocol`.
- `ClayBuilder` — result builder for low-level element trees.
- `ClayRenderCommand` / `ClayRenderCommandIterator` — inspect or iterate Clay render commands.
- `ClayMakeString` / `ClayFreeStringBuffers` — bridge Swift strings into Clay's temporary string storage.
- `ClayError` / `ClayErrorType` — typed Clay error reporting.

## Low-Level Example

```swift
import ClaySwift

@main
struct LowLevelDemo {
    @MainActor
    static func main() throws {
        let window = try ClayWindow(title: "Low Level", width: 800, height: 600)
        let fontId = try window.registerFont(name: "Body", size: 16)

        try window.run {
            ClayElement(
                "root",
                layout: ClayLayoutConfig(
                    sizing: .grow(),
                    padding: .init(24),
                    childGap: 12,
                    layoutDirection: .topToBottom
                ),
                backgroundColor: ClayColor(30, 30, 40)
            ) {
                ClayText(
                    "Hello from ClaySwift",
                    config: ClayTextConfig(
                        textColor: .white,
                        fontId: fontId,
                        fontSize: 24
                    )
                )

                ClayElement(
                    "box",
                    layout: ClayLayoutConfig(sizing: .fixed(width: 200, height: 80)),
                    backgroundColor: ClayColor(80, 140, 255),
                    cornerRadius: .init(8)
                )
            }
            .configure()
        }
    }
}
```

## Project Structure

```
Sources/
├── CClay/            Vendored Clay 0.14 implementation and headers
├── CSDLSupport/      System-library shim for SDL3 / SDL3_ttf / SDL3_image
├── CSDL3/            C renderer bridging Clay render commands to SDL3
└── ClaySwift/        Swift API
    ├── ClayApp.swift          App protocol and runtime
    ├── ClayScene.swift        WindowGroup scene
    ├── ClayView.swift         High-level views (Text, Button, stacks, ScrollView, ForEach)
    ├── ClayModifiers.swift    View modifiers
    ├── ClayState.swift        @State and bindings
    ├── ClayBuilder.swift      Low-level element declarations and result builder
    ├── ClayContext.swift      Clay context / arena / layout lifecycle
    ├── ClayWindow.swift       SDL3 window, events, render loop
    ├── ClayFontRegistry.swift Font discovery and registration
    ├── ClayImage.swift        Texture loading from file or data
    ├── ClayTypes.swift        Swift-to-Clay type mappings
    ├── ClayError.swift        Error types
    └── ClayRenderCommand.swift Render command wrappers
Examples/
├── BasicClayUI/      Compact ClaySwift example
├── BasicUI/          Larger ClaySwift example
└── BasicSwiftUI/     Native SwiftUI reference
Tests/
└── ClaySwiftTests/   Swift Testing suites
```

## Testing

```sh
swift test
```

The test suite uses [Swift Testing](https://github.com/swiftlang/swift-testing) and currently contains **71 tests across 12 suites**, covering:

- `Sendable` conformances
- Result builders and argument ordering
- Context initialization, layout begin/end, debug mode
- String bridging and UTF-8 handling
- Type conversions for sizing, alignment, wrapping, floating, and clipping
- Element, text, rectangle, border, and image element configuration
- Font registration, lookup, errors, and cleanup

## Platform Support and Limitations

- **macOS** is the declared platform (`macOS 13`). Linux and Windows code paths exist in the sources, but are not declared in `Package.swift` and have not been verified end-to-end.
- SDL3 libraries must be discoverable through `pkg-config`; the package does not vendor SDL.
- Homebrew SDL3 binaries may target a newer macOS release than the package's declared minimum. If the linker warns about a deployment-target mismatch, raise your app's macOS platform version.
- The app, scene, window, context, and state entry points are `@MainActor` isolated. Build and drive the UI from the main thread.
- The API is immediate-mode: `body` runs every frame. Keep view construction lightweight.
- `foregroundStyle` is currently a pass-through and does not change rendered text color. Use `ClayTextConfig.textColor` with the low-level API for custom text colors.
- There is no high-level `Image` view yet. `ClayImage` and `ClayImageElement` are available at the low level and require an SDL renderer pointer.
- Text input widgets (text fields, editors) are not implemented; keyboard state is exposed through `SDLInputState`.
- Clay is vendored at version **0.14**.

## Contributing

1. Install the SDL3 dependencies listed above.
2. Build with `swift build`.
3. Run the test suite with `swift test`.
4. Run an example with `swift run BasicClayUI` to verify rendering changes.

Please keep new public UI types `@MainActor`-safe and consistent with the existing `ClayView` / `ClayElementProtocol` layering.

## Acknowledgements

- [Clay](https://github.com/nicbarker/clay) by Nic Barker — the layout engine.
- [SDL3](https://github.com/libsdl-org/SDL), [SDL3_ttf](https://github.com/libsdl-org/SDL_ttf), and [SDL3_image](https://github.com/libsdl-org/SDL_image) — platform, text, and image support.
- The bundled SDL3 renderer is adapted from Clay's SDL3 example renderer.

## License

No license file has been specified for this repository yet.

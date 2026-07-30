import CClay
import CSDL3
import Foundation

// SDL3 window flags (macros unavailable in Swift)
private let SDL_WINDOW_RESIZABLE_FLAG: SDL_WindowFlags = 0x0000000000000020
private let SDL_WINDOW_HIGH_PIXEL_DENSITY_FLAG: SDL_WindowFlags = 0x0000000000002000
private let SDL_BUTTON_LMASK_VALUE: SDL_MouseButtonFlags = 1

// MARK: - ClayWindow

@MainActor
public final class ClayWindow {
    public let title: String
    public let width: Int32
    public let height: Int32

    nonisolated(unsafe) private var window: OpaquePointer? // SDL_Window*
    nonisolated(unsafe) private var renderer: OpaquePointer? // SDL_Renderer*
    nonisolated(unsafe) private var textEngine: OpaquePointer? // TTF_TextEngine*
    private var fontRegistry: ClayFontRegistry
    private var clayContext: ClayContext?
    private var isRunning = false
    private var lastFrameTime: UInt64 = 0
    private var currentDeltaTime: Float = 0
    public private(set) var input = SDLInputState()

    public init(title: String = "ClaySwift", width: Int32 = 1200, height: Int32 = 800) throws {
        self.title = title
        self.width = width
        self.height = height
        self.fontRegistry = ClayFontRegistry()
        try initializeSDL()
    }

    deinit {
        shutdown()
    }

    // MARK: - Setup

    private func initializeSDL() throws {
        guard SDL_Init(SDL_INIT_VIDEO) else {
            let error = String(cString: SDL_GetError())
            throw ClayWindowError.sdlInitFailed(error)
        }

        guard TTF_Init() else {
            let error = String(cString: SDL_GetError())
            throw ClayWindowError.ttfInitFailed(error)
        }
    }

    private func createWindowAndRenderer() throws {
        guard let win = SDL_CreateWindow(title, width, height, SDL_WINDOW_RESIZABLE_FLAG | SDL_WINDOW_HIGH_PIXEL_DENSITY_FLAG) else {
            let error = String(cString: SDL_GetError())
            throw ClayWindowError.windowCreationFailed(error)
        }
        self.window = win

        guard let rend = SDL_CreateRenderer(win, nil) else {
            let error = String(cString: SDL_GetError())
            throw ClayWindowError.rendererCreationFailed(error)
        }
        self.renderer = rend

        SDL_SetRenderVSync(rend, 1)

        guard let engine = TTF_CreateRendererTextEngine(rend) else {
            let error = String(cString: SDL_GetError())
            throw ClayWindowError.textEngineCreationFailed(error)
        }
        self.textEngine = engine
    }

    private func initializeClay() throws {
        let ctx = ClayContext(width: Float(width), height: Float(height))

        let registry = self.fontRegistry
        ctx.setMeasureTextFunction { textSlice, config, _ in
            guard let config = config else {
                return ClayDimensions(width: 0, height: 0)
            }
            let fontId = config.pointee.fontId
            let fontSize = config.pointee.fontSize

            guard let font = registry.font(byId: fontId) else {
                return ClayDimensions(width: 0, height: 0)
            }

            TTF_SetFontSize(font, Float(fontSize))
            var measuredWidth: Int32 = 0
            var measuredLength: Int = 0
            TTF_MeasureString(font, textSlice.baseChars, Int(textSlice.length), Int32.max, &measuredWidth, &measuredLength)
            let lineHeight = Float(TTF_GetFontHeight(font))
            return ClayDimensions(width: Float(measuredWidth), height: lineHeight)
        }

        self.clayContext = ctx
    }

    // MARK: - Font Registration

    @discardableResult
    public func registerFont(name: String, path: String? = nil, size: Int32 = 16) throws -> UInt16 {
        try fontRegistry.register(name: name, path: path, size: size)
    }

    public func fontId(named name: String) -> UInt16 {
        fontRegistry[name]
    }

    // MARK: - Main Loop

    public func run(_ layout: @escaping () -> Void) throws {
        try createWindowAndRenderer()
        try initializeClay()

        guard let renderer = renderer, let textEngine = textEngine else {
            throw ClayWindowError.notInitialized
        }

        fontRegistry.withFontArray { fontsPtr in
            Clay_SDL3_Initialize(renderer, textEngine, fontsPtr)
        }

        isRunning = true
        lastFrameTime = SDL_GetPerformanceCounter()

        while isRunning {
            let currentTime = SDL_GetPerformanceCounter()
            let deltaTime = Float(currentTime - lastFrameTime) / Float(SDL_GetPerformanceFrequency())
            lastFrameTime = currentTime
            currentDeltaTime = deltaTime

            handleEvents()
            renderFrame(layout: layout)
        }

        shutdown()
    }

    // MARK: - Event Handling

    private func handleEvents() {
        input.resetFrameState()

        var event = SDL_Event()

        while SDL_PollEvent(&event) {
            let eventType = event.type

            switch eventType {
            case UInt32(SDL_EVENT_QUIT.rawValue):
                isRunning = false

            case UInt32(SDL_EVENT_WINDOW_CLOSE_REQUESTED.rawValue):
                if event.window.windowID == SDL_GetWindowID(window) {
                    isRunning = false
                }

            case UInt32(SDL_EVENT_WINDOW_RESIZED.rawValue):
                if event.window.windowID == SDL_GetWindowID(window) {
                    clayContext?.setLayoutDimensions(
                        width: Float(event.window.data1),
                        height: Float(event.window.data2)
                    )
                }

            case UInt32(SDL_EVENT_MOUSE_MOTION.rawValue):
                input.mouseX = event.motion.x
                input.mouseY = event.motion.y
                let isDown = event.motion.state & SDL_BUTTON_LMASK_VALUE != 0
                input.mouseLeftDown = isDown
                clayContext?.setPointerState(
                    x: event.motion.x,
                    y: event.motion.y,
                    isDown: isDown
                )

            case UInt32(SDL_EVENT_MOUSE_BUTTON_DOWN.rawValue):
                input.mouseX = event.button.x
                input.mouseY = event.button.y
                if event.button.button == 1 {
                    input.mouseLeftDown = true
                    input.mouseLeftPressed = true
                }
                clayContext?.setPointerState(
                    x: event.button.x, y: event.button.y, isDown: true
                )

            case UInt32(SDL_EVENT_MOUSE_BUTTON_UP.rawValue):
                input.mouseX = event.button.x
                input.mouseY = event.button.y
                if event.button.button == 1 {
                    input.mouseLeftDown = false
                    input.mouseLeftReleased = true
                }
                clayContext?.setPointerState(
                    x: event.button.x, y: event.button.y, isDown: false
                )

            case UInt32(SDL_EVENT_MOUSE_WHEEL.rawValue):
                input.scrollX = event.wheel.x
                input.scrollY = event.wheel.y

            case UInt32(SDL_EVENT_KEY_DOWN.rawValue):
                let keycode = event.key.key
                input.keysDown.insert(keycode)
                input.keysPressed.insert(keycode)

            case UInt32(SDL_EVENT_KEY_UP.rawValue):
                let keycode = event.key.key
                input.keysDown.remove(keycode)
                input.keysReleased.insert(keycode)

            default:
                break
            }
        }
    }

    // MARK: - Rendering

    private func renderFrame(layout: () -> Void) {
        guard let ctx = clayContext, let renderer = renderer else { return }

        SDL_RenderClear(renderer)

        clayContext?.updateScrollContainers(
            enableDragScrolling: true,
            scrollDelta: ClayVector2(x: input.scrollX, y: input.scrollY),
            deltaTime: currentDeltaTime
        )

        _resetElementCounter()
        ctx.beginLayout()
        layout()
        var commands = ctx.endLayout(deltaTime: currentDeltaTime)

        fontRegistry.withFontArray { fontsPtr in
            Clay_SDL3_RenderCommands(&commands, fontsPtr)
        }

        SDL_RenderPresent(renderer)
        ClayFreeStringBuffers()
    }

    // MARK: - Shutdown

    private nonisolated func shutdown() {
        if let textEngine = textEngine { TTF_DestroyRendererTextEngine(textEngine); self.textEngine = nil }
        if let renderer = renderer { SDL_DestroyRenderer(renderer); self.renderer = nil }
        if let window = window { SDL_DestroyWindow(window); self.window = nil }
        TTF_Quit()
        SDL_Quit()
    }

    // MARK: - Context Access

    public var context: ClayContext? { clayContext }
    public var fontRegistryRef: ClayFontRegistry { fontRegistry }

    public func pointerOver(_ id: ClayID) -> Bool {
        clayContext?.pointerOver(id) ?? false
    }
}

// MARK: - Errors

public enum ClayWindowError: Error, CustomStringConvertible {
    case sdlInitFailed(String)
    case ttfInitFailed(String)
    case windowCreationFailed(String)
    case rendererCreationFailed(String)
    case textEngineCreationFailed(String)
    case notInitialized

    public var description: String {
        switch self {
        case .sdlInitFailed(let msg):
            return """
            SDL3 not found or failed to initialize: \(msg)
            Please install SDL3:
            - macOS: brew install sdl3 sdl3_ttf sdl3_image
            - Ubuntu/Debian: apt install libsdl3-dev libsdl3-ttf-dev libsdl3-image-dev
            - Windows: vcpkg install sdl3[sdl3-ttf,sdl3-image]
            """
        case .ttfInitFailed(let msg): return "SDL3_ttf initialization failed: \(msg)"
        case .windowCreationFailed(let msg): return "Failed to create SDL3 window: \(msg)"
        case .rendererCreationFailed(let msg): return "Failed to create SDL3 renderer: \(msg)"
        case .textEngineCreationFailed(let msg): return "Failed to create SDL3 text engine: \(msg)"
        case .notInitialized: return "ClayWindow not properly initialized"
        }
    }
}

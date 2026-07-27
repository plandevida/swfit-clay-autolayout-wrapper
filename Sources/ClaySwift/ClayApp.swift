import CSDL3
import Foundation

// MARK: - ClayApp Protocol

@MainActor
public protocol ClayApp {
    associatedtype Body: ClayScene
    @ClaySceneBuilder var body: Self.Body { get }
    init()
}

extension ClayApp {
    public static func main() {
        let app = Self()
        let runtime = ClayAppRuntime()
        ClayAppRuntime.current = runtime
        do {
            try runtime.run(app)
        } catch {
            print("[ClayApp] Fatal error: \(error)")
        }
    }
}

// MARK: - ClaySceneBuilder

@resultBuilder
public struct ClaySceneBuilder {
    public static func buildBlock<Content: ClayScene>(_ content: Content) -> Content {
        content
    }
}

// MARK: - ClayViewBuilder

@resultBuilder
public struct ClayViewBuilder {
    public static func buildBlock(_ components: [any ClayView]...) -> [any ClayView] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [any ClayView]?) -> [any ClayView] {
        component ?? []
    }

    public static func buildEither(first component: [any ClayView]) -> [any ClayView] {
        component
    }

    public static func buildEither(second component: [any ClayView]) -> [any ClayView] {
        component
    }

    public static func buildArray(_ components: [[any ClayView]]) -> [any ClayView] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [any ClayView]) -> [any ClayView] {
        component
    }

    public static func buildExpression<Content: ClayView>(_ expression: Content) -> [any ClayView] {
        [expression]
    }
}

// MARK: - ClayAppRuntime

public final class ClayAppRuntime {
    nonisolated(unsafe) public static var current: ClayAppRuntime?

    private var fontRegistry = ClayFontRegistry()
    private var stateValues: [String: Any] = [:]
    nonisolated(unsafe) private var _input: (() -> SDLInputState)?
    nonisolated(unsafe) private var _pointerOver: ((ClayID) -> Bool)?

    public init() {}

    @MainActor
    public func run<A: ClayApp>(_ app: A) throws {
        let scene = app.body
        guard let windowGroup = scene as? WindowGroup else {
            throw ClayAppError.noWindowGroup
        }

        let win = try ClayWindow(
            title: windowGroup.title,
            width: windowGroup.width,
            height: windowGroup.height
        )

        // Capture weak references for nonisolated access
        self._input = { [weak win] in win?.input ?? SDLInputState() }
        self._pointerOver = { [weak win] id in win?.pointerOver(id) ?? false }

        try fontRegistry.register(name: "ClayFont-16", size: 16)
        try fontRegistry.register(name: "ClayFont-24", size: 24)

        try win.run { [weak self] in
            guard let self = self else { return }
            let currentScene = app.body
            if let wg = currentScene as? WindowGroup {
                wg.configure(fontRegistry: self.fontRegistry)
            }
        }
    }

    // MARK: - State Management

    public func stateValue(for id: String) -> Any? {
        stateValues[id]
    }

    public func setStateValue(for id: String, value: Any) {
        stateValues[id] = value
    }

    // MARK: - Input

    public var input: SDLInputState {
        _input?() ?? SDLInputState()
    }

    public func pointerOver(_ id: ClayID) -> Bool {
        _pointerOver?(id) ?? false
    }
}

// MARK: - ClayAppError

public enum ClayAppError: Error, CustomStringConvertible {
    case noWindowGroup

    public var description: String {
        switch self {
        case .noWindowGroup:
            return "[ClayApp] App body must return a WindowGroup scene."
        }
    }
}

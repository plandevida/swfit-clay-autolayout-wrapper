import CClay

// MARK: - ClayContext

@MainActor
public final class ClayContext {
    nonisolated(unsafe) private var arenaBuffer: UnsafeMutableRawPointer?
    nonisolated(unsafe) private var contextPtr: OpaquePointer?

    public init(
        width: Float,
        height: Float,
        errorHandler: Clay_ErrorHandler? = nil
    ) {
        let minSize = Clay_MinMemorySize()
        arenaBuffer = UnsafeMutableRawPointer.allocate(byteCount: Int(minSize), alignment: 64)
        let arena = Clay_CreateArenaWithCapacityAndMemory(size_t(minSize), arenaBuffer!)

        let dims = Clay_Dimensions(width: width, height: height)
        let handler = errorHandler ?? Clay_ErrorHandler(
            errorHandlerFunction: { error in
                let text = error.errorText
                if let chars = text.chars, text.length > 0 {
                    let ptr = UnsafeRawPointer(chars)
                    let message = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: ptr), length: Int(text.length), encoding: .utf8, freeWhenDone: false) ?? "<unknown>"
                    print("[Clay Error] \(message)")
                }
            },
            userData: nil
        )
        contextPtr = Clay_Initialize(arena, dims, handler)
    }

    deinit {
        arenaBuffer?.deallocate()
    }

    // MARK: - Layout Dimensions

    public func setLayoutDimensions(width: Float, height: Float) {
        Clay_SetLayoutDimensions(Clay_Dimensions(width: width, height: height))
    }

    public func getLayoutDimensions() -> Clay_Dimensions {
        Clay_GetLayoutDimensions()
    }

    // MARK: - Pointer Hit Test

    public func pointerOver(_ id: ClayID) -> Bool {
        Clay_PointerOver(id.cElementId)
    }

    // MARK: - Internal Pointer/Scroll Feeding (called by ClayWindow from SDL3 events)

    internal func setPointerState(x: Float, y: Float, isDown: Bool) {
        Clay_SetPointerState(Clay_Vector2(x: x, y: y), isDown)
    }

    internal func updateScrollContainers(
        enableDragScrolling: Bool,
        scrollDelta: ClayVector2,
        deltaTime: Float
    ) {
        Clay_UpdateScrollContainers(enableDragScrolling, scrollDelta, deltaTime)
    }

    // MARK: - Layout

    public func beginLayout() {
        Clay_BeginLayout()
    }

    public func endLayout(deltaTime: Float = 0) -> Clay_RenderCommandArray {
        Clay_EndLayout(deltaTime)
    }

    // MARK: - Measure Text

    public func setMeasureTextFunction(
        _ callback: @escaping (Clay_StringSlice, UnsafeMutablePointer<Clay_TextElementConfig>?, UnsafeMutableRawPointer?) -> ClayDimensions
    ) {
        let boxed = Unmanaged.passRetained(BoxedMeasureTextCallback(callback)).toOpaque()
        Clay_SetMeasureTextFunction({ textSlice, config, userData in
            guard let userData = userData else {
                return ClayDimensions(width: 0, height: 0)
            }
            let boxed = Unmanaged<BoxedMeasureTextCallback>.fromOpaque(userData).takeUnretainedValue()
            return boxed.callback(textSlice, config, userData)
        }, boxed)
    }

    // MARK: - Debug

    public func setDebugModeEnabled(_ enabled: Bool) {
        Clay_SetDebugModeEnabled(enabled)
    }

    public func isDebugModeEnabled() -> Bool {
        Clay_IsDebugModeEnabled()
    }

    // MARK: - Element Data

    public func getElementData(id: ClayID) -> Clay_ElementData {
        Clay_GetElementData(id.cElementId)
    }
}

// MARK: - Boxed Callback Helpers

private final class BoxedMeasureTextCallback {
    let callback: (Clay_StringSlice, UnsafeMutablePointer<Clay_TextElementConfig>?, UnsafeMutableRawPointer?) -> ClayDimensions
    init(_ callback: @escaping (Clay_StringSlice, UnsafeMutablePointer<Clay_TextElementConfig>?, UnsafeMutableRawPointer?) -> ClayDimensions) {
        self.callback = callback
    }
}

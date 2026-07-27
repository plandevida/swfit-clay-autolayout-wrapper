import CClay
#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(WinSDK)
    import WinSDK
#endif

// MARK: - C Enum Helpers

// CLAY_PACKED_ENUM is imported as opaque types in Swift.
// We use unsafeBitCast to create values from raw UInt8.

func _clayEnum<T>(_ value: UInt8) -> T {
    unsafeBitCast(value, to: T.self)
}

// Layout direction
let CLAY_LEFT_TO_RIGHT_U8: UInt8 = 0
let CLAY_TOP_TO_BOTTOM_U8: UInt8 = 1

// Alignment X
let CLAY_ALIGN_X_LEFT_U8: UInt8 = 0
let CLAY_ALIGN_X_RIGHT_U8: UInt8 = 1
let CLAY_ALIGN_X_CENTER_U8: UInt8 = 2

// Alignment Y
let CLAY_ALIGN_Y_TOP_U8: UInt8 = 0
let CLAY_ALIGN_Y_BOTTOM_U8: UInt8 = 1
let CLAY_ALIGN_Y_CENTER_U8: UInt8 = 2

// Sizing type
let CLAY__SIZING_TYPE_FIT_U8: UInt8 = 0
let CLAY__SIZING_TYPE_GROW_U8: UInt8 = 1
let CLAY__SIZING_TYPE_PERCENT_U8: UInt8 = 2
let CLAY__SIZING_TYPE_FIXED_U8: UInt8 = 3

// Text wrap mode
let CLAY_TEXT_WRAP_WORDS_U8: UInt8 = 0
let CLAY_TEXT_WRAP_NEWLINES_U8: UInt8 = 1
let CLAY_TEXT_WRAP_NONE_U8: UInt8 = 2

// Text alignment
let CLAY_TEXT_ALIGN_LEFT_U8: UInt8 = 0
let CLAY_TEXT_ALIGN_CENTER_U8: UInt8 = 1
let CLAY_TEXT_ALIGN_RIGHT_U8: UInt8 = 2

// Floating attach to
let CLAY_ATTACH_TO_NONE_U8: UInt8 = 0
let CLAY_ATTACH_TO_PARENT_U8: UInt8 = 1
let CLAY_ATTACH_TO_ELEMENT_WITH_ID_U8: UInt8 = 2
let CLAY_ATTACH_TO_ROOT_U8: UInt8 = 3

// Floating clip to
let CLAY_CLIP_TO_NONE_U8: UInt8 = 0
let CLAY_CLIP_TO_ATTACHED_PARENT_U8: UInt8 = 1

// Pointer capture mode
let CLAY_POINTER_CAPTURE_MODE_CAPTURE_U8: UInt8 = 0
let CLAY_POINTER_CAPTURE_MODE_PASSTHROUGH_U8: UInt8 = 1

// Attach point types (0-8)
let CLAY_ATTACH_POINT_LEFT_TOP_U8: UInt8 = 0
let CLAY_ATTACH_POINT_LEFT_CENTER_U8: UInt8 = 1
let CLAY_ATTACH_POINT_LEFT_BOTTOM_U8: UInt8 = 2
let CLAY_ATTACH_POINT_CENTER_TOP_U8: UInt8 = 3
let CLAY_ATTACH_POINT_CENTER_CENTER_U8: UInt8 = 4
let CLAY_ATTACH_POINT_CENTER_BOTTOM_U8: UInt8 = 5
let CLAY_ATTACH_POINT_RIGHT_TOP_U8: UInt8 = 6
let CLAY_ATTACH_POINT_RIGHT_CENTER_U8: UInt8 = 7
let CLAY_ATTACH_POINT_RIGHT_BOTTOM_U8: UInt8 = 8

// MARK: - Type Aliases

public typealias ClayVector2 = Clay_Vector2
public typealias ClayBoundingBox = Clay_BoundingBox
public typealias ClayDimensions = Clay_Dimensions

// MARK: - ClayColor

public struct ClayColor: Sendable {
    public var r: Float
    public var g: Float
    public var b: Float
    public var a: Float

    public init(r: Float, g: Float, b: Float, a: Float = 255) {
        self.r = r; self.g = g; self.b = b; self.a = a
    }

    public init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8 = 255) {
        self.r = Float(r); self.g = Float(g); self.b = Float(b); self.a = Float(a)
    }

    public var cClayColor: Clay_Color {
        Clay_Color(r: r, g: g, b: b, a: a)
    }

    public static let clear = ClayColor(0, 0, 0, 0)
    public static let white = ClayColor(255, 255, 255)
    public static let black = ClayColor(0, 0, 0)
    public static let red = ClayColor(255, 0, 0)
    public static let green = ClayColor(0, 255, 0)
    public static let blue = ClayColor(0, 0, 255)
    public static let gray = ClayColor(128, 128, 128)
    public static let lightGray = ClayColor(200, 200, 200)
    public static let darkGray = ClayColor(50, 50, 50)
    public static let transparent = ClayColor(0, 0, 0, 0)
}

// MARK: - ClayID

public struct ClayID: Sendable {
    public var string: String
    public var index: UInt32?

    public init(_ string: String, index: UInt32? = nil) {
        self.string = string
        self.index = index
    }

    public var cElementId: Clay_ElementId {
        if let index = index {
            return Clay__HashStringWithOffset(ClayMakeString(string), index, 0)
        }
        return Clay__HashString(ClayMakeString(string), 0)
    }
}

// MARK: - ClayPadding

public struct ClayPadding: Sendable {
    public var left: UInt16
    public var right: UInt16
    public var top: UInt16
    public var bottom: UInt16

    public init(left: UInt16 = 0, right: UInt16 = 0, top: UInt16 = 0, bottom: UInt16 = 0) {
        self.left = left; self.right = right; self.top = top; self.bottom = bottom
    }

    public init(_ all: UInt16) {
        left = all; right = all; top = all; bottom = all
    }

    public init(horizontal: UInt16, vertical: UInt16) {
        left = horizontal; right = horizontal; top = vertical; bottom = vertical
    }

    public var cPadding: Clay_Padding {
        Clay_Padding(left: left, right: right, top: top, bottom: bottom)
    }

    public static let zero = ClayPadding(0)
}

// MARK: - ClayCornerRadius

public struct ClayCornerRadius: Sendable {
    public var topLeft: Float
    public var topRight: Float
    public var bottomLeft: Float
    public var bottomRight: Float

    public init(topLeft: Float = 0, topRight: Float = 0, bottomLeft: Float = 0, bottomRight: Float = 0) {
        self.topLeft = topLeft; self.topRight = topRight; self.bottomLeft = bottomLeft; self.bottomRight = bottomRight
    }

    public init(_ all: Float) {
        topLeft = all; topRight = all; bottomLeft = all; bottomRight = all
    }

    public var cCornerRadius: Clay_CornerRadius {
        Clay_CornerRadius(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
    }

    public static let zero = ClayCornerRadius(0)
}

// MARK: - ClaySizing

public enum ClaySizingAxis: Sendable {
    case fit
    case grow(max: Float? = nil)
    case fixed(Float)
    case percent(Float)

    var cSizingAxis: Clay_SizingAxis {
        var axis = Clay_SizingAxis()
        switch self {
        case .fit:
            axis.type = _clayEnum(CLAY__SIZING_TYPE_FIT_U8)
            axis.size.minMax = Clay_SizingMinMax(min: 0, max: 0)
        case let .grow(max):
            axis.type = _clayEnum(CLAY__SIZING_TYPE_GROW_U8)
            axis.size.minMax = Clay_SizingMinMax(min: 0, max: max ?? 0)
        case let .fixed(value):
            axis.type = _clayEnum(CLAY__SIZING_TYPE_FIXED_U8)
            axis.size.minMax = Clay_SizingMinMax(min: value, max: value)
        case let .percent(value):
            axis.type = _clayEnum(CLAY__SIZING_TYPE_PERCENT_U8)
            axis.size.percent = value
        }
        return axis
    }
}

public struct ClaySizing {
    public var width: ClaySizingAxis
    public var height: ClaySizingAxis

    public init(width: ClaySizingAxis = .fit, height: ClaySizingAxis = .fit) {
        self.width = width; self.height = height
    }

    public init(_ axis: ClaySizingAxis) {
        width = axis; height = axis
    }

    public static func fixed(width: Float, height: Float) -> ClaySizing {
        ClaySizing(width: .fixed(width), height: .fixed(height))
    }

    public static func grow(maxWidth: Float? = nil, maxHeight: Float? = nil) -> ClaySizing {
        ClaySizing(width: .grow(max: maxWidth), height: .grow(max: maxHeight))
    }

    var cSizing: Clay_Sizing {
        Clay_Sizing(width: width.cSizingAxis, height: height.cSizingAxis)
    }
}

// MARK: - ClayAlignment

public enum ClayAlignmentX: UInt8, Sendable {
    case left = 0, right = 1, center = 2
    var cAlignmentX: Clay_LayoutAlignmentX {
        _clayEnum(rawValue)
    }
}

public enum ClayAlignmentY: UInt8, Sendable {
    case top = 0, bottom = 1, center = 2
    var cAlignmentY: Clay_LayoutAlignmentY {
        _clayEnum(rawValue)
    }
}

public struct ClayChildAlignment: Sendable {
    public var x: ClayAlignmentX
    public var y: ClayAlignmentY

    public init(x: ClayAlignmentX = .left, y: ClayAlignmentY = .top) {
        self.x = x; self.y = y
    }

    public static let center = ClayChildAlignment(x: .center, y: .center)

    var cChildAlignment: Clay_ChildAlignment {
        Clay_ChildAlignment(x: x.cAlignmentX, y: y.cAlignmentY)
    }
}

// MARK: - ClayLayoutDirection

public enum ClayLayoutDirection: Sendable {
    case leftToRight, topToBottom
    var cLayoutDirection: Clay_LayoutDirection {
        switch self {
        case .leftToRight: return _clayEnum(CLAY_LEFT_TO_RIGHT_U8)
        case .topToBottom: return _clayEnum(CLAY_TOP_TO_BOTTOM_U8)
        }
    }
}

// MARK: - ClayLayoutConfig

public struct ClayLayoutConfig {
    public var sizing: ClaySizing
    public var padding: ClayPadding
    public var childGap: UInt16
    public var childAlignment: ClayChildAlignment
    public var layoutDirection: ClayLayoutDirection?

    public init(
        sizing: ClaySizing = .init(),
        padding: ClayPadding = .zero,
        childGap: UInt16 = 0,
        childAlignment: ClayChildAlignment = .init(),
        layoutDirection: ClayLayoutDirection? = nil
    ) {
        self.sizing = sizing; self.padding = padding
        self.childGap = childGap; self.childAlignment = childAlignment
        self.layoutDirection = layoutDirection
    }

    var cLayoutConfig: Clay_LayoutConfig {
        var config = Clay_LayoutConfig(
            sizing: sizing.cSizing,
            padding: padding.cPadding,
            childGap: childGap,
            childAlignment: childAlignment.cChildAlignment,
            layoutDirection: _clayEnum(CLAY_LEFT_TO_RIGHT_U8)
        )
        if let dir = layoutDirection {
            config.layoutDirection = dir.cLayoutDirection
        }
        return config
    }
}

// MARK: - ClayTextConfig

public struct ClayTextConfig: Sendable {
    public nonisolated(unsafe) var userData: UnsafeMutableRawPointer?
    public var textColor: ClayColor
    public var fontId: UInt16
    public var fontSize: UInt16
    public var letterSpacing: UInt16
    public var lineHeight: UInt16
    public var wrapMode: ClayTextWrapMode
    public var textAlignment: ClayTextAlignment

    public init(
        textColor: ClayColor = .black, fontId: UInt16 = 0, fontSize: UInt16 = 16,
        letterSpacing: UInt16 = 0, lineHeight: UInt16 = 0,
        wrapMode: ClayTextWrapMode = .words, textAlignment: ClayTextAlignment = .left
    ) {
        userData = nil; self.textColor = textColor; self.fontId = fontId
        self.fontSize = fontSize; self.letterSpacing = letterSpacing
        self.lineHeight = lineHeight; self.wrapMode = wrapMode
        self.textAlignment = textAlignment
    }

    var cTextElementConfig: Clay_TextElementConfig {
        Clay_TextElementConfig(
            userData: userData, textColor: textColor.cClayColor,
            fontId: fontId, fontSize: fontSize,
            letterSpacing: letterSpacing, lineHeight: lineHeight,
            wrapMode: wrapMode.cWrapMode, textAlignment: textAlignment.cTextAlignment
        )
    }
}

public enum ClayTextWrapMode: Sendable {
    case words, newlines, none
    var cWrapMode: Clay_TextElementConfigWrapMode {
        switch self {
        case .words: return _clayEnum(CLAY_TEXT_WRAP_WORDS_U8)
        case .newlines: return _clayEnum(CLAY_TEXT_WRAP_NEWLINES_U8)
        case .none: return _clayEnum(CLAY_TEXT_WRAP_NONE_U8)
        }
    }
}

public enum ClayTextAlignment: Sendable {
    case left, center, right
    var cTextAlignment: Clay_TextAlignment {
        switch self {
        case .left: return _clayEnum(CLAY_TEXT_ALIGN_LEFT_U8)
        case .center: return _clayEnum(CLAY_TEXT_ALIGN_CENTER_U8)
        case .right: return _clayEnum(CLAY_TEXT_ALIGN_RIGHT_U8)
        }
    }
}

// MARK: - ClayBorderConfig

public struct ClayBorderWidth {
    public var left: UInt16
    public var right: UInt16
    public var top: UInt16
    public var bottom: UInt16
    public var betweenChildren: UInt16

    public init(left: UInt16 = 0, right: UInt16 = 0, top: UInt16 = 0, bottom: UInt16 = 0, betweenChildren: UInt16 = 0) {
        self.left = left; self.right = right; self.top = top
        self.bottom = bottom; self.betweenChildren = betweenChildren
    }

    public init(_ all: UInt16) {
        left = all; right = all; top = all
        bottom = all; betweenChildren = 0
    }

    var cBorderWidth: Clay_BorderWidth {
        Clay_BorderWidth(left: left, right: right, top: top, bottom: bottom, betweenChildren: betweenChildren)
    }
}

public struct ClayBorderConfig {
    public var width: ClayBorderWidth
    public var color: ClayColor
    public var cornerRadius: ClayCornerRadius

    public init(width: ClayBorderWidth = .init(0), color: ClayColor = .clear, cornerRadius: ClayCornerRadius = .zero) {
        self.width = width; self.color = color; self.cornerRadius = cornerRadius
    }

    public init(_ width: UInt16, color: ClayColor = .black, cornerRadius: ClayCornerRadius = .zero) {
        self.width = ClayBorderWidth(width); self.color = color; self.cornerRadius = cornerRadius
    }

    var cBorderElementConfig: Clay_BorderElementConfig {
        Clay_BorderElementConfig(color: color.cClayColor, width: width.cBorderWidth)
    }
}

// MARK: - ClayFloatingConfig

public enum ClayFloatingAttachTo: Sendable {
    case none, parent, elementWithID(ClayID), root
    var cAttachTo: Clay_FloatingAttachToElement {
        switch self {
        case .none: return _clayEnum(CLAY_ATTACH_TO_NONE_U8)
        case .parent: return _clayEnum(CLAY_ATTACH_TO_PARENT_U8)
        case .elementWithID: return _clayEnum(CLAY_ATTACH_TO_ELEMENT_WITH_ID_U8)
        case .root: return _clayEnum(CLAY_ATTACH_TO_ROOT_U8)
        }
    }
}

public enum ClayFloatingClipTo: Sendable {
    case none, attachedParent
    var cClipTo: Clay_FloatingClipToElement {
        switch self {
        case .none: return _clayEnum(CLAY_CLIP_TO_NONE_U8)
        case .attachedParent: return _clayEnum(CLAY_CLIP_TO_ATTACHED_PARENT_U8)
        }
    }
}

public enum ClayPointerCaptureMode: Sendable {
    case capture, passthrough
    var cPointerCaptureMode: Clay_PointerCaptureMode {
        switch self {
        case .capture: return _clayEnum(CLAY_POINTER_CAPTURE_MODE_CAPTURE_U8)
        case .passthrough: return _clayEnum(CLAY_POINTER_CAPTURE_MODE_PASSTHROUGH_U8)
        }
    }
}

public enum ClayAttachPoint: Sendable {
    case leftTop, leftCenter, leftBottom
    case centerTop, centerCenter, centerBottom
    case rightTop, rightCenter, rightBottom

    var cAttachPoint: Clay_FloatingAttachPointType {
        switch self {
        case .leftTop: return _clayEnum(CLAY_ATTACH_POINT_LEFT_TOP_U8)
        case .leftCenter: return _clayEnum(CLAY_ATTACH_POINT_LEFT_CENTER_U8)
        case .leftBottom: return _clayEnum(CLAY_ATTACH_POINT_LEFT_BOTTOM_U8)
        case .centerTop: return _clayEnum(CLAY_ATTACH_POINT_CENTER_TOP_U8)
        case .centerCenter: return _clayEnum(CLAY_ATTACH_POINT_CENTER_CENTER_U8)
        case .centerBottom: return _clayEnum(CLAY_ATTACH_POINT_CENTER_BOTTOM_U8)
        case .rightTop: return _clayEnum(CLAY_ATTACH_POINT_RIGHT_TOP_U8)
        case .rightCenter: return _clayEnum(CLAY_ATTACH_POINT_RIGHT_CENTER_U8)
        case .rightBottom: return _clayEnum(CLAY_ATTACH_POINT_RIGHT_BOTTOM_U8)
        }
    }
}

public struct ClayFloatingConfig {
    public var offset: ClayVector2
    public var expand: ClayDimensions
    public var parentId: ClayID?
    public var zIndex: Int16
    public var attachPoints: (element: ClayAttachPoint, parent: ClayAttachPoint)
    public var pointerCaptureMode: ClayPointerCaptureMode
    public var attachTo: ClayFloatingAttachTo
    public var clipTo: ClayFloatingClipTo

    public init(
        offset: ClayVector2 = ClayVector2(x: 0, y: 0),
        expand: ClayDimensions = ClayDimensions(width: 0, height: 0),
        parentId: ClayID? = nil, zIndex: Int16 = 0,
        attachPoints: (element: ClayAttachPoint, parent: ClayAttachPoint) = (.centerCenter, .centerCenter),
        pointerCaptureMode: ClayPointerCaptureMode = .capture,
        attachTo: ClayFloatingAttachTo = .none,
        clipTo: ClayFloatingClipTo = .none
    ) {
        self.offset = offset; self.expand = expand; self.parentId = parentId
        self.zIndex = zIndex; self.attachPoints = attachPoints
        self.pointerCaptureMode = pointerCaptureMode; self.attachTo = attachTo; self.clipTo = clipTo
    }

    var cFloatingConfig: Clay_FloatingElementConfig {
        Clay_FloatingElementConfig(
            offset: offset, expand: expand,
            parentId: parentId?.cElementId.id ?? 0, zIndex: zIndex,
            attachPoints: Clay_FloatingAttachPoints(
                element: attachPoints.element.cAttachPoint,
                parent: attachPoints.parent.cAttachPoint
            ),
            pointerCaptureMode: pointerCaptureMode.cPointerCaptureMode,
            attachTo: attachTo.cAttachTo, clipTo: clipTo.cClipTo
        )
    }
}

// MARK: - ClayClipConfig

public struct ClayClipConfig {
    public var horizontal: Bool
    public var vertical: Bool
    public var childOffset: ClayVector2

    public init(horizontal: Bool = true, vertical: Bool = true, childOffset: ClayVector2 = ClayVector2(x: 0, y: 0)) {
        self.horizontal = horizontal; self.vertical = vertical; self.childOffset = childOffset
    }

    var cClipConfig: Clay_ClipElementConfig {
        Clay_ClipElementConfig(horizontal: horizontal, vertical: vertical, childOffset: childOffset)
    }
}

// MARK: - ClayAspectRatioConfig

public struct ClayAspectRatioConfig {
    public var ratio: Float
    public init(_ ratio: Float) {
        self.ratio = ratio
    }

    var cAspectRatioConfig: Clay_AspectRatioElementConfig {
        Clay_AspectRatioElementConfig(aspectRatio: ratio)
    }
}

// MARK: - SDLInputState

public struct SDLInputState: Sendable {
    public var mouseX: Float = 0
    public var mouseY: Float = 0
    public var mouseLeftDown: Bool = false
    public var mouseLeftPressed: Bool = false
    public var mouseLeftReleased: Bool = false
    public var scrollX: Float = 0
    public var scrollY: Float = 0
    public var keysDown: Set<UInt32> = []
    public var keysPressed: Set<UInt32> = []
    public var keysReleased: Set<UInt32> = []

    public init() {}

    mutating func resetFrameState() {
        mouseLeftPressed = false
        mouseLeftReleased = false
        scrollX = 0
        scrollY = 0
        keysPressed.removeAll()
        keysReleased.removeAll()
    }
}

// MARK: - String Helpers

private nonisolated(unsafe) var clayStringBuffers: [UnsafeMutablePointer<CChar>] = []

private func clayAllocateString(_ bytes: [UInt8]) -> UnsafeMutablePointer<CChar> {
    let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bytes.count + 1)
    for i in 0 ..< bytes.count {
        buffer[i] = CChar(bitPattern: bytes[i])
    }
    buffer[bytes.count] = 0
    clayStringBuffers.append(buffer)
    return buffer
}

public func ClayFreeStringBuffers() {
    for buf in clayStringBuffers {
        buf.deallocate()
    }
    clayStringBuffers.removeAll()
}

public func ClayMakeString(_ string: String) -> Clay_String {
    let bytes = Array(string.utf8)
    let buffer = clayAllocateString(bytes)
    return Clay_String(isStaticallyAllocated: false, length: Int32(bytes.count), chars: buffer)
}

public func ClayMakeString(_ buffer: UnsafePointer<CChar>, length: Int32) -> Clay_String {
    Clay_String(isStaticallyAllocated: false, length: length, chars: buffer)
}

import CClay
import Foundation

// MARK: - ClayView Protocol

public protocol ClayView {
    func configure(fontRegistry: ClayFontRegistry)
}

// MARK: - ClayViewAdapter (bridges ClayView to ClayElementProtocol)

struct ClayViewAdapter: ClayElementProtocol {
    let view: any ClayView
    let fontRegistry: ClayFontRegistry

    func configure() {
        view.configure(fontRegistry: fontRegistry)
    }
}

// MARK: - Text

public struct Text: ClayView {
    let text: String
    var font: ClayFont = .system(size: 16)
    var textColor: ClayColor = .black
    var textAlignment: ClayTextAlignment = .left

    public init(_ text: String) {
        self.text = text
    }

    public func configure(fontRegistry: ClayFontRegistry) {
        let fontId = fontRegistry.registerOrFind(font: font)
        ClayText(text, config: ClayTextConfig(
            textColor: textColor,
            fontId: fontId,
            fontSize: font.size,
            textAlignment: textAlignment
        )).configure()
    }
}

// MARK: - Button

public struct Button: ClayView {
    let label: String
    let action: () -> Void
    let id: String
    var backgroundColor: ClayColor = .init(50, 120, 220)
    var cornerRadius: ClayCornerRadius = .init(8)
    var labelFont: ClayFont = .system(size: 16)
    var labelColor: ClayColor = .white
    var sizing: ClaySizing = .init(width: .fixed(200), height: .fixed(50))
    var childAlignment: ClayChildAlignment = .center

    public init(_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
        // Must be stable across frames so pointerOver() matches the element ID
        // stored in pointerOverIds from the event handling pass.
        id = "button_\(label.hashValue)"
    }

    public func configure(fontRegistry: ClayFontRegistry) {
        let elementId = ClayID(id)
        ClayElement(id,
                    layout: ClayLayoutConfig(
                        sizing: sizing,
                        childAlignment: childAlignment
                    ),
                    backgroundColor: backgroundColor,
                    cornerRadius: cornerRadius)
        {
            ClayText(label, config: ClayTextConfig(
                textColor: labelColor,
                fontId: fontRegistry.registerOrFind(font: labelFont),
                fontSize: labelFont.size
            ))
        }.configure()

        if ClayAppRuntime.current?.input.mouseLeftReleased == true,
           ClayAppRuntime.current?.pointerOver(elementId) == true
        {
            action()
        }
    }
}

// MARK: - VStack

public struct VStack: ClayView {
    let spacing: UInt16
    let alignment: ClayChildAlignment
    let children: [any ClayView]

    public init(
        alignment: ClayChildAlignment = .init(x: .left, y: .top),
        spacing: UInt16 = 8,
        @ClayViewBuilder content: () -> [any ClayView]
    ) {
        self.spacing = spacing
        self.alignment = alignment
        children = content()
    }

    public func configure(fontRegistry: ClayFontRegistry) {
        ClayElement(nil,
                    layout: ClayLayoutConfig(
                        sizing: .grow(),
                        childGap: spacing,
                        childAlignment: alignment,
                        layoutDirection: .topToBottom
                    )) {
            for child in children {
                ClayViewAdapter(view: child, fontRegistry: fontRegistry)
            }
        }.configure()
    }
}

// MARK: - HStack

public struct HStack: ClayView {
    let spacing: UInt16
    let alignment: ClayChildAlignment
    let children: [any ClayView]

    public init(
        alignment: ClayChildAlignment = .init(x: .left, y: .top),
        spacing: UInt16 = 8,
        @ClayViewBuilder content: () -> [any ClayView]
    ) {
        self.spacing = spacing
        self.alignment = alignment
        children = content()
    }

    public func configure(fontRegistry: ClayFontRegistry) {
        ClayElement(nil,
                    layout: ClayLayoutConfig(
                        sizing: .grow(),
                        childGap: spacing,
                        childAlignment: alignment,
                        layoutDirection: .leftToRight
                    )) {
            for child in children {
                ClayViewAdapter(view: child, fontRegistry: fontRegistry)
            }
        }.configure()
    }
}

// MARK: - ForEach

public struct ForEach<Content: ClayView>: ClayView {
    let children: [Content]

    public init(_ data: Range<Int>, @ClayViewBuilder content: (Int) -> Content) {
        children = data.map { content($0) }
    }

    public init<C: Collection, ID: Hashable>(_ data: C, id _: KeyPath<C.Element, ID>, content: @escaping (C.Element, Int) -> Content) {
        children = data.enumerated().map { content($0.element, $0.offset) }
    }

    public func configure(fontRegistry: ClayFontRegistry) {
        for child in children {
            child.configure(fontRegistry: fontRegistry)
        }
    }
}

// MARK: - ConditionalContent (for if/else)

public enum _ConditionalContent<TrueContent: ClayView, FalseContent: ClayView>: ClayView {
    case trueContent(TrueContent)
    case falseContent(FalseContent)

    public func configure(fontRegistry: ClayFontRegistry) {
        switch self {
        case let .trueContent(content):
            content.configure(fontRegistry: fontRegistry)
        case let .falseContent(content):
            content.configure(fontRegistry: fontRegistry)
        }
    }
}

// MARK: - EmptyView

public struct EmptyView: ClayView {
    public init() {}

    public func configure(fontRegistry _: ClayFontRegistry) {}
}

// MARK: - ScrollView

public struct ScrollView: ClayView {
    let vertical: Bool
    let horizontal: Bool
    let children: [any ClayView]

    public init(
        _ axes: Axis.Set = .vertical,
        @ClayViewBuilder content: () -> [any ClayView]
    ) {
        vertical = axes.contains(.vertical)
        horizontal = axes.contains(.horizontal)
        children = content()
    }

    public func configure(fontRegistry: ClayFontRegistry) {
        let scrollId = Clay__HashString(ClayMakeString("__scroll_\(_nextStableElementId())"), 0)

        Clay__OpenElementWithId(scrollId)

        // Must call Clay_GetScrollOffset() while the element is open to get
        // the scroll container's current position from internal persistent state.
        let scrollOffset = Clay_GetScrollOffset()

        var decl = clayDefaultDecl()
        decl.layout = ClayLayoutConfig(
            sizing: .grow(),
            childGap: 0,
            layoutDirection: vertical ? .topToBottom : .leftToRight
        ).cLayoutConfig
        decl.clip = ClayClipConfig(
            horizontal: horizontal,
            vertical: vertical,
            childOffset: scrollOffset
        ).cClipConfig
        Clay__ConfigureOpenElementPtr(&decl)
        for child in children {
            ClayViewAdapter(view: child, fontRegistry: fontRegistry).configure()
        }
        Clay__CloseElement()
    }
}

// MARK: - Axis

public struct Axis: OptionSet, Sendable, Hashable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let horizontal = Axis(rawValue: 1 << 0)
    public static let vertical = Axis(rawValue: 1 << 1)
    public static let all: Axis = [.horizontal, .vertical]
}

public extension Axis {
    struct Set: OptionSet, Sendable, Hashable {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public static let horizontal = Set(rawValue: 1 << 0)
        public static let vertical = Set(rawValue: 1 << 1)
        public static let all: Set = [.horizontal, .vertical]
    }
}

import CClay
import Foundation

// MARK: - ClayView Protocol

public protocol ClayView {
    func configure(fontRegistry: ClayFontRegistry)
}

// MARK: - ClayViewAdapter (bridges ClayView to ClayElementProtocol)

internal struct ClayViewAdapter: ClayElementProtocol {
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
        ))
    }
}

// MARK: - Button

public struct Button: ClayView {
    let label: String
    let action: () -> Void
    let id: String
    var backgroundColor: ClayColor = ClayColor(50, 120, 220)
    var cornerRadius: ClayCornerRadius = ClayCornerRadius(8)
    var labelFont: ClayFont = .system(size: 16)
    var labelColor: ClayColor = .white
    var sizing: ClaySizing = ClaySizing(width: .fixed(200), height: .fixed(50))
    var childAlignment: ClayChildAlignment = .center

    public init(_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
        self.id = "button_\(UUID().uuidString)"
    }

    public func configure(fontRegistry: ClayFontRegistry) {
        let elementId = ClayID(id)
        ClayElement(id,
            layout: ClayLayoutConfig(
                sizing: sizing,
                childAlignment: childAlignment
            ),
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius
        ) {
            ClayText(label, config: ClayTextConfig(
                textColor: labelColor,
                fontId: fontRegistry.registerOrFind(font: labelFont),
                fontSize: labelFont.size
            ))
        }.configure()

        if ClayAppRuntime.current?.input.mouseLeftReleased == true,
           ClayAppRuntime.current?.pointerOver(elementId) == true {
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
        self.children = content()
    }

    public func configure(fontRegistry: ClayFontRegistry) {
        ClayElement(nil,
            layout: ClayLayoutConfig(
                sizing: .grow(),
                childGap: spacing,
                childAlignment: alignment,
                layoutDirection: .topToBottom
            )
        ) {
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
        self.children = content()
    }

    public func configure(fontRegistry: ClayFontRegistry) {
        ClayElement(nil,
            layout: ClayLayoutConfig(
                sizing: .grow(),
                childGap: spacing,
                childAlignment: alignment,
                layoutDirection: .leftToRight
            )
        ) {
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
        self.children = data.map { content($0) }
    }

    public init<C: Collection, ID: Hashable>(_ data: C, id: KeyPath<C.Element, ID>, content: @escaping (C.Element) -> Content) {
        self.children = data.map { content($0) }
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
        case .trueContent(let content):
            content.configure(fontRegistry: fontRegistry)
        case .falseContent(let content):
            content.configure(fontRegistry: fontRegistry)
        }
    }
}

// MARK: - EmptyView

public struct EmptyView: ClayView {
    public init() {}

    public func configure(fontRegistry: ClayFontRegistry) {}
}

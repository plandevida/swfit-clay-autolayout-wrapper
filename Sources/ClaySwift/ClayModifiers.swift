import CClay
import Foundation

// MARK: - ViewModifier Protocol

public protocol ViewModifier {
    func modify<V: ClayView>(_ content: V, fontRegistry: ClayFontRegistry)
}

// MARK: - ModifiedContent

public struct ModifiedContent<Content: ClayView, Modifier: ViewModifier>: ClayView {
    let content: Content
    let modifier: Modifier

    public init(_ content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }

    public func configure(fontRegistry: ClayFontRegistry) {
        modifier.modify(content, fontRegistry: fontRegistry)
    }
}

// MARK: - Helper

private func defaultClayLayout() -> Clay_LayoutConfig {
    Clay_LayoutConfig(
        sizing: ClaySizing.grow().cSizing,
        padding: Clay_Padding(left: 0, right: 0, top: 0, bottom: 0),
        childGap: 0,
        childAlignment: Clay_ChildAlignment(
            x: _clayEnum(CLAY_ALIGN_X_LEFT_U8),
            y: _clayEnum(CLAY_ALIGN_Y_TOP_U8)
        ),
        layoutDirection: _clayEnum(CLAY_LEFT_TO_RIGHT_U8)
    )
}

// MARK: - PaddingModifier

public struct PaddingModifier: ViewModifier {
    let padding: ClayPadding

    public init(_ padding: ClayPadding) {
        self.padding = padding
    }

    public func modify<V: ClayView>(_ content: V, fontRegistry: ClayFontRegistry) {
        let elementId = Clay__HashString(ClayMakeString("__padding_\(_nextStableElementId())"), 0)
        var decl = clayDefaultDecl()
        decl.layout = ClayLayoutConfig(
            sizing: .grow(),
            padding: padding,
            childGap: 0,
            childAlignment: .init(x: .left, y: .top),
            layoutDirection: .leftToRight
        ).cLayoutConfig

        Clay__OpenElementWithId(elementId)
        Clay__ConfigureOpenElementPtr(&decl)
        content.configure(fontRegistry: fontRegistry)
        Clay__CloseElement()
    }
}

// MARK: - BackgroundModifier

public struct BackgroundModifier: ViewModifier {
    let color: ClayColor

    public init(_ color: ClayColor) {
        self.color = color
    }

    public func modify<V: ClayView>(_ content: V, fontRegistry: ClayFontRegistry) {
        let elementId = Clay__HashString(ClayMakeString("__bg_\(_nextStableElementId())"), 0)
        var decl = clayDefaultDecl()
        decl.layout = defaultClayLayout()
        decl.backgroundColor = color.cClayColor

        Clay__OpenElementWithId(elementId)
        Clay__ConfigureOpenElementPtr(&decl)
        content.configure(fontRegistry: fontRegistry)
        Clay__CloseElement()
    }
}

// MARK: - ForegroundStyleModifier

public struct ForegroundStyleModifier: ViewModifier {
    let color: ClayColor

    public init(_ color: ClayColor) {
        self.color = color
    }

    public func modify<V: ClayView>(_ content: V, fontRegistry: ClayFontRegistry) {
        content.configure(fontRegistry: fontRegistry)
    }
}

// MARK: - FrameModifier

public struct FrameModifier: ViewModifier {
    let width: Float?
    let height: Float?
    let maxWidth: Float?
    let maxHeight: Float?
    let alignment: ClayChildAlignment

    public init(
        width: Float? = nil,
        height: Float? = nil,
        maxWidth: Float? = nil,
        maxHeight: Float? = nil,
        alignment: ClayChildAlignment = .init(x: .left, y: .top)
    ) {
        self.width = width
        self.height = height
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.alignment = alignment
    }

    public func modify<V: ClayView>(_ content: V, fontRegistry: ClayFontRegistry) {
        let elementId = Clay__HashString(ClayMakeString("__frame_\(_nextStableElementId())"), 0)

        var widthAxis: ClaySizingAxis = .grow()
        var heightAxis: ClaySizingAxis = .grow()

        if let w = width {
            widthAxis = .fixed(w)
        } else if let mw = maxWidth {
            widthAxis = .grow(max: mw)
        }

        if let h = height {
            heightAxis = .fixed(h)
        } else if let mh = maxHeight {
            heightAxis = .grow(max: mh)
        }

        var decl = clayDefaultDecl()
        decl.layout = ClayLayoutConfig(
            sizing: ClaySizing(width: widthAxis, height: heightAxis),
            padding: .zero,
            childGap: 0,
            childAlignment: alignment,
            layoutDirection: .leftToRight
        ).cLayoutConfig

        Clay__OpenElementWithId(elementId)
        Clay__ConfigureOpenElementPtr(&decl)
        content.configure(fontRegistry: fontRegistry)
        Clay__CloseElement()
    }
}

// MARK: - FontModifier

public struct FontModifier: ViewModifier {
    let font: ClayFont

    public init(_ font: ClayFont) {
        self.font = font
    }

    public func modify<V: ClayView>(_ content: V, fontRegistry: ClayFontRegistry) {
        content.configure(fontRegistry: fontRegistry)
    }
}

// MARK: - CornerRadiusModifier

public struct CornerRadiusModifier: ViewModifier {
    let cornerRadius: ClayCornerRadius

    public init(_ radius: Float) {
        self.cornerRadius = ClayCornerRadius(radius)
    }

    public func modify<V: ClayView>(_ content: V, fontRegistry: ClayFontRegistry) {
        let elementId = Clay__HashString(ClayMakeString("__cr_\(_nextStableElementId())"), 0)
        var decl = clayDefaultDecl()
        decl.layout = defaultClayLayout()
        decl.cornerRadius = cornerRadius.cCornerRadius

        Clay__OpenElementWithId(elementId)
        Clay__ConfigureOpenElementPtr(&decl)
        content.configure(fontRegistry: fontRegistry)
        Clay__CloseElement()
    }
}

// MARK: - BorderModifier

public struct BorderModifier: ViewModifier {
    let borderConfig: ClayBorderConfig

    public init(_ width: UInt16, color: ClayColor = .black, cornerRadius: ClayCornerRadius = .zero) {
        self.borderConfig = ClayBorderConfig(width: ClayBorderWidth(width), color: color, cornerRadius: cornerRadius)
    }

    public func modify<V: ClayView>(_ content: V, fontRegistry: ClayFontRegistry) {
        let elementId = Clay__HashString(ClayMakeString("__border_\(_nextStableElementId())"), 0)
        var decl = clayDefaultDecl()
        decl.layout = defaultClayLayout()
        decl.border = borderConfig.cBorderElementConfig
        decl.cornerRadius = borderConfig.cornerRadius.cCornerRadius

        Clay__OpenElementWithId(elementId)
        Clay__ConfigureOpenElementPtr(&decl)
        content.configure(fontRegistry: fontRegistry)
        Clay__CloseElement()
    }
}

// MARK: - View Extension (Modifier API)

extension ClayView {
    public func padding(_ length: UInt16) -> ModifiedContent<Self, PaddingModifier> {
        ModifiedContent(self, modifier: PaddingModifier(ClayPadding(length)))
    }

    public func padding(_ edges: ClayEdge, _ length: UInt16) -> ModifiedContent<Self, PaddingModifier> {
        var padding = ClayPadding(0)
        if edges.contains(.leading) { padding.left = length }
        if edges.contains(.trailing) { padding.right = length }
        if edges.contains(.top) { padding.top = length }
        if edges.contains(.bottom) { padding.bottom = length }
        return ModifiedContent(self, modifier: PaddingModifier(padding))
    }

    public func background(_ color: ClayColor) -> ModifiedContent<Self, BackgroundModifier> {
        ModifiedContent(self, modifier: BackgroundModifier(color))
    }

    public func foregroundStyle(_ color: ClayColor) -> ModifiedContent<Self, ForegroundStyleModifier> {
        ModifiedContent(self, modifier: ForegroundStyleModifier(color))
    }

    public func frame(
        width: Float? = nil,
        height: Float? = nil,
        maxWidth: Float? = nil,
        maxHeight: Float? = nil,
        alignment: ClayChildAlignment = .init(x: .left, y: .top)
    ) -> ModifiedContent<Self, FrameModifier> {
        ModifiedContent(self, modifier: FrameModifier(
            width: width, height: height,
            maxWidth: maxWidth, maxHeight: maxHeight,
            alignment: alignment
        ))
    }

    public func font(_ font: ClayFont) -> ModifiedContent<Self, FontModifier> {
        ModifiedContent(self, modifier: FontModifier(font))
    }

    public func cornerRadius(_ radius: Float) -> ModifiedContent<Self, CornerRadiusModifier> {
        ModifiedContent(self, modifier: CornerRadiusModifier(radius))
    }

    public func border(_ width: UInt16, color: ClayColor = .black) -> ModifiedContent<Self, BorderModifier> {
        ModifiedContent(self, modifier: BorderModifier(width, color: color))
    }
}

// MARK: - ClayEdge

public struct ClayEdge: OptionSet, Sendable, Hashable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let leading = ClayEdge(rawValue: 1 << 0)
    public static let trailing = ClayEdge(rawValue: 1 << 1)
    public static let top = ClayEdge(rawValue: 1 << 2)
    public static let bottom = ClayEdge(rawValue: 1 << 3)
    public static let horizontal: ClayEdge = [.leading, .trailing]
    public static let vertical: ClayEdge = [.top, .bottom]
    public static let all: ClayEdge = [.horizontal, .vertical]
}

// MARK: - Text Convenience

extension Text {
    public func foregroundStyle(_ color: ClayColor) -> ModifiedContent<Text, ForegroundStyleModifier> {
        ModifiedContent(self, modifier: ForegroundStyleModifier(color))
    }

    public func font(_ font: ClayFont) -> Text {
        var copy = self
        copy.font = font
        return copy
    }

    public func textAlignment(_ alignment: ClayTextAlignment) -> Text {
        var copy = self
        copy.textAlignment = alignment
        return copy
    }
}

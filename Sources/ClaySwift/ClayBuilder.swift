import CClay
import Foundation

// MARK: - Stable Element ID Counter

private let _elementCounterQueue = DispatchQueue(label: "com.clay.elementCounter")
private nonisolated(unsafe) var _globalElementCounter: UInt32 = 0

internal func _nextStableElementId() -> UInt32 {
    _elementCounterQueue.sync {
        _globalElementCounter += 1
        return _globalElementCounter
    }
}

internal func _resetElementCounter() {
    _elementCounterQueue.sync {
        _globalElementCounter = 0
    }
}

// MARK: - ClayElementProtocol

public protocol ClayElementProtocol {
    func configure()
}

// MARK: - Default Clay_ElementDeclaration

internal func clayDefaultDecl() -> Clay_ElementDeclaration {
    Clay_ElementDeclaration(
        layout: Clay_LayoutConfig(),
        backgroundColor: Clay_Color(),
        overlayColor: Clay_Color(),
        cornerRadius: Clay_CornerRadius(),
        aspectRatio: Clay_AspectRatioElementConfig(),
        image: Clay_ImageElementConfig(),
        floating: Clay_FloatingElementConfig(),
        custom: Clay_CustomElementConfig(),
        clip: Clay_ClipElementConfig(),
        border: Clay_BorderElementConfig(),
        transition: Clay_TransitionElementConfig(),
        userData: nil
    )
}

// MARK: - ClayElement (Container)

public struct ClayElement: ClayElementProtocol {
    public let id: ClayID
    public let layout: ClayLayoutConfig?
    public let backgroundColor: ClayColor?
    public let overlayColor: ClayColor?
    public let cornerRadius: ClayCornerRadius?
    public let floating: ClayFloatingConfig?
    public let clip: ClayClipConfig?
    public let border: ClayBorderConfig?
    public let aspectRatio: ClayAspectRatioConfig?
    public let children: [ClayElementProtocol]

    public init(
        _ id: String? = nil,
        layout: ClayLayoutConfig? = nil,
        backgroundColor: ClayColor? = nil,
        overlayColor: ClayColor? = nil,
        cornerRadius: ClayCornerRadius? = nil,
        floating: ClayFloatingConfig? = nil,
        clip: ClayClipConfig? = nil,
        border: ClayBorderConfig? = nil,
        aspectRatio: ClayAspectRatioConfig? = nil,
        @ClayBuilder children: () -> [ClayElementProtocol] = { [] }
    ) {
        self.id = ClayID(id ?? UUID().uuidString)
        self.layout = layout
        self.backgroundColor = backgroundColor
        self.overlayColor = overlayColor
        self.cornerRadius = cornerRadius
        self.floating = floating
        self.clip = clip
        self.border = border
        self.aspectRatio = aspectRatio
        self.children = children()
    }

    public func configure() {
        var sizing = Clay_Sizing()
        sizing.width.type = _clayEnum(CLAY__SIZING_TYPE_GROW_U8)
        sizing.width.size.minMax = Clay_SizingMinMax(min: 0, max: 0)
        sizing.height.type = _clayEnum(CLAY__SIZING_TYPE_GROW_U8)
        sizing.height.size.minMax = Clay_SizingMinMax(min: 0, max: 0)

        var decl = clayDefaultDecl()
        decl.layout = layout?.cLayoutConfig ?? Clay_LayoutConfig(
            sizing: sizing,
            padding: Clay_Padding(left: 0, right: 0, top: 0, bottom: 0),
            childGap: 0,
            childAlignment: Clay_ChildAlignment(
                x: _clayEnum(CLAY_ALIGN_X_LEFT_U8),
                y: _clayEnum(CLAY_ALIGN_Y_TOP_U8)
            ),
            layoutDirection: _clayEnum(CLAY_LEFT_TO_RIGHT_U8)
        )
        if let bg = backgroundColor { decl.backgroundColor = bg.cClayColor }
        if let ov = overlayColor { decl.overlayColor = ov.cClayColor }
        if let cr = cornerRadius { decl.cornerRadius = cr.cCornerRadius }
        if let ar = aspectRatio { decl.aspectRatio = ar.cAspectRatioConfig }
        if let fl = floating { decl.floating = fl.cFloatingConfig }
        if let cl = clip { decl.clip = cl.cClipConfig }
        if let bd = border { decl.border = bd.cBorderElementConfig }

        Clay__OpenElementWithId(id.cElementId)
        Clay__ConfigureOpenElementPtr(&decl)
        for child in children { child.configure() }
        Clay__CloseElement()
    }
}

// MARK: - ClayText

public struct ClayText: ClayElementProtocol {
    public let text: String
    public let config: ClayTextConfig

    public init(_ text: String, config: ClayTextConfig = ClayTextConfig()) {
        self.text = text
        self.config = config
    }

    public func configure() {
        let cConfig = config.cTextElementConfig
        Clay__OpenTextElement(ClayMakeString(text), cConfig)
    }
}

// MARK: - ClayRectangle

public struct ClayRectangle: ClayElementProtocol {
    public let color: ClayColor
    public let cornerRadius: ClayCornerRadius

    public init(color: ClayColor = .clear, cornerRadius: ClayCornerRadius = .zero) {
        self.color = color
        self.cornerRadius = cornerRadius
    }

    public func configure() {
        let elementId = Clay__HashString(ClayMakeString("__rect_\(_nextStableElementId())"), 0)
        var decl = clayDefaultDecl()
        decl.backgroundColor = color.cClayColor
        decl.cornerRadius = cornerRadius.cCornerRadius

        Clay__OpenElementWithId(elementId)
        Clay__ConfigureOpenElementPtr(&decl)
        Clay__CloseElement()
    }
}

// MARK: - ClayImageElement

public struct ClayImageElement: ClayElementProtocol {
    public let image: ClayImage
    public let tint: ClayColor

    public init(_ image: ClayImage, tint: ClayColor = .white) {
        self.image = image
        self.tint = tint
    }

    public func configure() {
        let elementId = Clay__HashString(ClayMakeString("__img_\(_nextStableElementId())"), 0)
        var decl = clayDefaultDecl()
        decl.image = Clay_ImageElementConfig(imageData: image.texturePtr)

        Clay__OpenElementWithId(elementId)
        Clay__ConfigureOpenElementPtr(&decl)
        Clay__CloseElement()
    }
}

// MARK: - ClayBorderElement

public struct ClayBorderElement: ClayElementProtocol {
    public let config: ClayBorderConfig

    public init(_ config: ClayBorderConfig) {
        self.config = config
    }

    public init(_ width: UInt16, color: ClayColor = .black, cornerRadius: ClayCornerRadius = .zero) {
        self.config = ClayBorderConfig(width: ClayBorderWidth(width), color: color, cornerRadius: cornerRadius)
    }

    public func configure() {
        let elementId = Clay__HashString(ClayMakeString("__border_\(_nextStableElementId())"), 0)
        var decl = clayDefaultDecl()
        decl.cornerRadius = config.cornerRadius.cCornerRadius
        decl.border = config.cBorderElementConfig

        Clay__OpenElementWithId(elementId)
        Clay__ConfigureOpenElementPtr(&decl)
        Clay__CloseElement()
    }
}

// MARK: - @resultBuilder

@resultBuilder
public struct ClayBuilder {
    public static func buildBlock(_ components: [ClayElementProtocol]...) -> [ClayElementProtocol] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [ClayElementProtocol]?) -> [ClayElementProtocol] {
        component ?? []
    }

    public static func buildEither(first component: [ClayElementProtocol]) -> [ClayElementProtocol] {
        component
    }

    public static func buildEither(second component: [ClayElementProtocol]) -> [ClayElementProtocol] {
        component
    }

    public static func buildArray(_ components: [[ClayElementProtocol]]) -> [ClayElementProtocol] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [ClayElementProtocol]) -> [ClayElementProtocol] {
        component
    }

    public static func buildExpression(_ expression: ClayElementProtocol) -> [ClayElementProtocol] {
        [expression]
    }
}

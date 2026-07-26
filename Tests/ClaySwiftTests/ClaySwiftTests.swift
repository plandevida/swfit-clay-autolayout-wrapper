import Testing
import CClay
@testable import ClaySwift

// MARK: - Sendable Conformance

@Suite("Sendable Conformance", .serialized)
struct SendableTests {

    @Test func clayColorIsSendable() {
        let _: Sendable = ClayColor.red
    }

    @Test func clayPaddingIsSendable() {
        let _: Sendable = ClayPadding(16)
    }

    @Test func clayCornerRadiusIsSendable() {
        let _: Sendable = ClayCornerRadius(8)
    }

    @Test func clayIDIsSendable() {
        let _: Sendable = ClayID("test")
    }

    @Test func claySizingAxisIsSendable() {
        let _: Sendable = ClaySizingAxis.fixed(200)
    }

    @Test func clayAlignmentIsSendable() {
        let _: Sendable = ClayChildAlignment.center
    }

    @Test func clayLayoutDirectionIsSendable() {
        let _: Sendable = ClayLayoutDirection.leftToRight
    }

    @Test func clayTextWrapModeIsSendable() {
        let _: Sendable = ClayTextWrapMode.words
    }

    @Test func clayTextAlignmentIsSendable() {
        let _: Sendable = ClayTextAlignment.center
    }

    @Test func clayFloatingAttachToIsSendable() {
        let _: Sendable = ClayFloatingAttachTo.parent
    }

    @Test func clayFloatingClipToIsSendable() {
        let _: Sendable = ClayFloatingClipTo.none
    }

    @Test func clayPointerCaptureModeIsSendable() {
        let _: Sendable = ClayPointerCaptureMode.capture
    }

    @Test func clayAttachPointIsSendable() {
        let _: Sendable = ClayAttachPoint.centerCenter
    }

    @Test func clayErrorTypeIsSendable() {
        let _: Sendable = ClayErrorType.arenaCapacityExceeded
    }
}

// MARK: - Result Builder

@Suite("Result Builder", .serialized)
struct ResultBuilderTests {

    @Test func singleExpression() {
        let elements = ClayBuilder.buildExpression(ClayText("hello"))
        #expect(elements.count == 1)
        #expect(elements[0] is ClayText)
    }

    @Test func multipleExpressions() {
        let e1 = ClayBuilder.buildExpression(ClayText("a"))
        let e2 = ClayBuilder.buildExpression(ClayText("b"))
        let result = ClayBuilder.buildBlock(e1, e2)
        #expect(result.count == 2)
    }

    @Test func optionalNone() {
        let result = ClayBuilder.buildOptional(nil)
        #expect(result.isEmpty)
    }

    @Test func optionalSome() {
        let elements = ClayBuilder.buildExpression(ClayText("present"))
        let result = ClayBuilder.buildOptional(elements)
        #expect(result.count == 1)
    }

    @Test func eitherFirst() {
        let left = ClayBuilder.buildExpression(ClayText("left"))
        let result = ClayBuilder.buildEither(first: left)
        #expect(result.count == 1)
    }

    @Test func eitherSecond() {
        let right = ClayBuilder.buildExpression(ClayText("right"))
        let result = ClayBuilder.buildEither(second: right)
        #expect(result.count == 1)
    }

    @Test func buildArray() {
        let a = ClayBuilder.buildExpression(ClayText("a"))
        let b = ClayBuilder.buildExpression(ClayText("b"))
        let result = ClayBuilder.buildArray([a, b])
        #expect(result.count == 2)
    }

    @Test func elementWithBuilder() {
        let el = ClayElement("parent") {
            ClayText("child1")
            ClayText("child2")
        }
        #expect(el.children.count == 2)
    }

    @Test func elementWithForLoop() {
        let el = ClayElement("list") {
            for i in 1...3 {
                ClayText("item \(i)")
            }
        }
        #expect(el.children.count == 3)
    }

    @Test func elementWithConditional() {
        let show = true
        let el = ClayElement("cond") {
            if show {
                ClayText("visible")
            } else {
                ClayText("hidden")
            }
        }
        #expect(el.children.count == 1)
    }
}

// MARK: - Argument Ordering

@Suite("Argument Ordering", .serialized)
struct ArgumentOrderingTests {

    @Test func layoutConfigTextColorFirst() {
        let config = ClayTextConfig(
            textColor: .blue,
            fontId: 0,
            fontSize: 16,
            letterSpacing: 0,
            lineHeight: 20,
            wrapMode: .words,
            textAlignment: .left
        )
        #expect(config.fontSize == 16)
    }

    @Test func layoutConfigChildGapBeforeLayoutDirection() {
        let config = ClayLayoutConfig(
            sizing: .init(),
            padding: ClayPadding(8),
            childGap: 4,
            childAlignment: .center,
            layoutDirection: .topToBottom
        )
        #expect(config.childGap == 4)
        #expect(config.layoutDirection == .topToBottom)
    }

    @Test func layoutConfigMinimalArgs() {
        let config = ClayLayoutConfig(
            sizing: .init(width: .fixed(100), height: .grow(max: nil)),
            padding: ClayPadding(4)
        )
        #expect(config.childGap == 0)
    }
}

// MARK: - ClayContext

@Suite("ClayContext", .serialized)
struct ClayContextTests {

    @Test func initialize() {
        let ctx = ClayContext(width: 800, height: 600)
        let dims = ctx.getLayoutDimensions()
        #expect(dims.width == 800)
        #expect(dims.height == 600)
    }

    @Test func setLayoutDimensions() {
        let ctx = ClayContext(width: 800, height: 600)
        ctx.setLayoutDimensions(width: 1920, height: 1080)
        let dims = ctx.getLayoutDimensions()
        #expect(dims.width == 1920)
        #expect(dims.height == 1080)
    }

    @Test func sdlInputStateDefaults() {
        let input = SDLInputState()
        #expect(input.mouseX == 0)
        #expect(input.mouseY == 0)
        #expect(input.mouseLeftDown == false)
        #expect(input.mouseLeftPressed == false)
        #expect(input.mouseLeftReleased == false)
        #expect(input.keysDown.isEmpty)
    }

    @Test func sdlInputStateResetFrameState() {
        var input = SDLInputState()
        input.mouseLeftPressed = true
        input.mouseLeftReleased = true
        input.scrollX = 5
        input.scrollY = 3
        input.keysPressed.insert(42)
        input.keysReleased.insert(99)
        input.resetFrameState()
        #expect(input.mouseLeftPressed == false)
        #expect(input.mouseLeftReleased == false)
        #expect(input.scrollX == 0)
        #expect(input.scrollY == 0)
        #expect(input.keysPressed.isEmpty)
        #expect(input.keysReleased.isEmpty)
    }

    @Test func beginEndLayout() {
        let ctx = ClayContext(width: 800, height: 600)
        ctx.beginLayout()
        let commands = ctx.endLayout(deltaTime: 0.016)
        #expect(commands.length >= 0)
    }

    @Test func debugMode() {
        let ctx = ClayContext(width: 800, height: 600)
        ctx.setDebugModeEnabled(true)
        #expect(ctx.isDebugModeEnabled() == true)
        ctx.setDebugModeEnabled(false)
        #expect(ctx.isDebugModeEnabled() == false)
    }
}

// MARK: - ClayMakeString

@Suite("ClayMakeString Extended", .serialized)
struct ClayMakeStringTests {

    @Test func emptyString() {
        let s = ClayMakeString("")
        #expect(s.length == 0)
        #expect(s.chars != nil)
    }

    @Test func unicodeString() {
        let s = ClayMakeString("Hello 🌍")
        #expect(s.length > 0)
    }

    @Test func bufferLengthMatchesUTF8() {
        let str = "ClaySwift"
        let s = ClayMakeString(str)
        #expect(s.length == Int32(str.utf8.count))
    }
}

// MARK: - Clay Types Extended

@Suite("Clay Types Extended", .serialized)
struct ClayTypesExtendedTests {

    @Test func sizingFit() {
        if case .fit = ClaySizingAxis.fit {
            // ok
        } else {
            Issue.record("Expected fit sizing")
        }
    }

    @Test func sizingGrowDefault() {
        if case .grow(let max) = ClaySizingAxis.grow(max: nil) {
            #expect(max == nil)
        } else {
            Issue.record("Expected grow with nil max")
        }
    }

    @Test func sizingWidthHeight() {
        let sizing = ClaySizing(width: .fixed(100), height: .grow(max: nil))
        #expect(sizing.cSizing.width.type.rawValue != 0)
    }

    @Test func layoutDirectionRoundtrip() {
        let ltr = ClayLayoutDirection.leftToRight
        let ttb = ClayLayoutDirection.topToBottom
        #expect(ltr.cLayoutDirection != ttb.cLayoutDirection)
    }

    @Test func alignmentRoundtrip() {
        let left = ClayAlignmentX.left
        let center = ClayAlignmentX.center
        let right = ClayAlignmentX.right
        #expect(left.cAlignmentX != center.cAlignmentX)
        #expect(center.cAlignmentX != right.cAlignmentX)
    }

    @Test func textWrapModeRoundtrip() {
        let words = ClayTextWrapMode.words
        let none = ClayTextWrapMode.none
        #expect(words.cWrapMode != none.cWrapMode)
    }

    @Test func textAlignmentRoundtrip() {
        let left = ClayTextAlignment.left
        let center = ClayTextAlignment.center
        let right = ClayTextAlignment.right
        #expect(left.cTextAlignment != center.cTextAlignment)
        #expect(center.cTextAlignment != right.cTextAlignment)
    }

    @Test func attachPointAllCases() {
        let points: [ClayAttachPoint] = [
            .leftTop, .leftCenter, .leftBottom,
            .centerTop, .centerCenter, .centerBottom,
            .rightTop, .rightCenter, .rightBottom
        ]
        #expect(points.count == 9)
    }

    @Test func floatingAttachToAllCases() {
        #expect(ClayFloatingAttachTo.none.cAttachTo != ClayFloatingAttachTo.parent.cAttachTo)
        #expect(ClayFloatingAttachTo.parent.cAttachTo != ClayFloatingAttachTo.root.cAttachTo)
    }

    @Test func floatingClipToAllCases() {
        #expect(ClayFloatingClipTo.none.cClipTo != ClayFloatingClipTo.attachedParent.cClipTo)
    }

    @Test func pointerCaptureModeAllCases() {
        #expect(ClayPointerCaptureMode.capture.cPointerCaptureMode != ClayPointerCaptureMode.passthrough.cPointerCaptureMode)
    }
}

// MARK: - ClayElement Configuration

@Suite("ClayElement Configuration", .serialized)
struct ClayElementTests {

    @Test func elementDefaultID() {
        let el = ClayElement()
        #expect(!el.id.string.isEmpty)
    }

    @Test func elementCustomID() {
        let el = ClayElement("my-id")
        #expect(el.id.string == "my-id")
    }

    @Test func elementWithBackgroundColor() {
        let el = ClayElement("bg", backgroundColor: .red)
        #expect(el.backgroundColor != nil)
        #expect(el.backgroundColor?.r == 255)
    }

    @Test func elementWithCornerRadius() {
        let el = ClayElement("cr", cornerRadius: ClayCornerRadius(10))
        #expect(el.cornerRadius != nil)
        #expect(el.cornerRadius?.topLeft == 10)
    }

    @Test func elementWithBorder() {
        let border = ClayBorderConfig(2, color: .black, cornerRadius: ClayCornerRadius(4))
        let el = ClayElement("bd", border: border)
        #expect(el.border != nil)
    }

    @Test func elementWithLayout() {
        let layout = ClayLayoutConfig(sizing: .init(width: .fixed(200), height: .grow(max: nil)))
        let el = ClayElement("ly", layout: layout)
        #expect(el.layout != nil)
    }

    @Test func elementConfigureOpensAndCloses() {
        let ctx = ClayContext(width: 800, height: 600)
        ctx.beginLayout()
        let el = ClayElement("test-configure") {
            ClayText("child")
        }
        el.configure()
        let commands = ctx.endLayout(deltaTime: 0.016)
        #expect(commands.length >= 0)
    }
}

// MARK: - ClayText Configuration

@Suite("ClayText Configuration", .serialized)
struct ClayTextTests {

    @Test func textDefault() {
        let t = ClayText("hello")
        #expect(t.text == "hello")
    }

    @Test func textConfigureInLayout() {
        let ctx = ClayContext(width: 800, height: 600)
        ctx.beginLayout()
        let t = ClayText("test", config: ClayTextConfig(textColor: .red, fontId: 0, fontSize: 14))
        t.configure()
        let commands = ctx.endLayout(deltaTime: 0.016)
        #expect(commands.length >= 0)
    }
}

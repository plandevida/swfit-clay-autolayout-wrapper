import CClay

// MARK: - ClayRenderCommand

public struct ClayRenderCommand {
    public let boundingBox: Clay_BoundingBox
    public let renderData: Clay_RenderData
    public let commandType: Clay_RenderCommandType
    public let id: UInt32
    public let zIndex: Int16

    internal init(from cCommand: Clay_RenderCommand) {
        self.boundingBox = cCommand.boundingBox
        self.renderData = cCommand.renderData
        self.commandType = cCommand.commandType
        self.id = cCommand.id
        self.zIndex = cCommand.zIndex
    }
}

// MARK: - ClayRenderCommandIterator

public struct ClayRenderCommandIterator: Sequence {
    private let commandArray: Clay_RenderCommandArray

    public init(_ array: Clay_RenderCommandArray) {
        self.commandArray = array
    }

    public func makeIterator() -> Iterator {
        Iterator(commands: commandArray)
    }

    public struct Iterator: IteratorProtocol {
        private var commands: Clay_RenderCommandArray
        private var index: Int32 = 0

        init(commands: Clay_RenderCommandArray) {
            self.commands = commands
        }

        public mutating func next() -> ClayRenderCommand? {
            guard index < commands.length else { return nil }
            guard let cmd = Clay_RenderCommandArray_Get(&commands, index) else {
                index += 1
                return nil
            }
            let result = ClayRenderCommand(from: cmd.pointee)
            index += 1
            return result
        }
    }
}

// MARK: - RenderCommandType Helpers

extension ClayRenderCommand {
    public var isRectangle: Bool { commandType == CLAY_RENDER_COMMAND_TYPE_RECTANGLE }
    public var isText: Bool { commandType == CLAY_RENDER_COMMAND_TYPE_TEXT }
    public var isBorder: Bool { commandType == CLAY_RENDER_COMMAND_TYPE_BORDER }
    public var isImage: Bool { commandType == CLAY_RENDER_COMMAND_TYPE_IMAGE }
    public var isScissorStart: Bool { commandType == CLAY_RENDER_COMMAND_TYPE_SCISSOR_START }
    public var isScissorEnd: Bool { commandType == CLAY_RENDER_COMMAND_TYPE_SCISSOR_END }
}

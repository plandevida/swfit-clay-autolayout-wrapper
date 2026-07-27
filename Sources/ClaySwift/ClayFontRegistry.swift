import CSDL3
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(WinSDK)
import WinSDK
#endif

// MARK: - System Font Resolution

public func findSystemFont() -> String {
    #if canImport(Darwin)
    let candidates = ["/System/Library/Fonts/Helvetica.ttc"]
    #elseif canImport(Glibc)
    let candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
        "/usr/share/fonts/TTF/DejaVuSans.ttf",
    ]
    #elseif canImport(WinSDK)
    let candidates = [
        "C:\\Windows\\Fonts\\arial.ttf",
        "C:\\Windows\\Fonts\\times.ttf",
    ]
    #else
    let candidates: [String] = []
    #endif
    for path in candidates {
        if access(path, F_OK) == 0 { return path }
    }
    return "/System/Library/Fonts/Helvetica.ttc"
}

// MARK: - ClayFontRegistry Errors

public enum ClayFontRegistryError: Error, CustomStringConvertible {
    case fontLoadFailed(name: String, path: String, message: String)
    case fontNotFound(name: String)

    public var description: String {
        switch self {
        case .fontLoadFailed(let name, let path, let message):
            return "[ClayFontRegistry] Failed to load font '\(name)' from '\(path)': \(message)"
        case .fontNotFound(let name):
            return "[ClayFontRegistry] Font '\(name)' not registered. Call register() first."
        }
    }
}

// MARK: - ClayFontRegistry

public final class ClayFontRegistry: @unchecked Sendable {
    private var fonts: [UInt16: OpaquePointer] = [:] // fontId -> TTF_Font*
    private var fontNames: [String: UInt16] = [:]   // name -> fontId
    private var nextId: UInt16 = 0
    private var fontArray: [OpaquePointer?] = []     // indexed by fontId for C renderer

    public init() {}

    deinit {
        for (_, font) in fonts {
            TTF_CloseFont(font)
        }
    }

    @discardableResult
    public func register(name: String, path: String? = nil, size: Int32 = 16) throws -> UInt16 {
        let resolvedPath = path ?? findSystemFont()
        guard let font = TTF_OpenFont(resolvedPath, Float(size)) else {
            let error = String(cString: SDL_GetError())
            throw ClayFontRegistryError.fontLoadFailed(name: name, path: resolvedPath, message: error)
        }

        let id = nextId
        nextId += 1
        fonts[id] = font
        fontNames[name] = id

        while fontArray.count <= Int(id) {
            fontArray.append(nil)
        }
        fontArray[Int(id)] = font

        return id
    }

    public func font(byId id: UInt16) -> OpaquePointer? {
        fonts[id]
    }

    public func fontId(named name: String) -> UInt16? {
        fontNames[name]
    }

    public func fontId(named name: String) throws -> UInt16 {
        guard let id = fontNames[name] else {
            throw ClayFontRegistryError.fontNotFound(name: name)
        }
        return id
    }

    public subscript(name: String) -> UInt16 {
        get {
            guard let id = fontNames[name] else {
                fatalError("[ClayFontRegistry] Font '\(name)' not registered. Call register() first.")
            }
            return id
        }
    }

    @discardableResult
    public func registerOrFind(font: ClayFont) -> UInt16 {
        let name = font.registerName
        if let existingId = fontId(named: name) {
            return existingId
        }
        switch font {
        case .system(let size):
            return try! register(name: name, size: Int32(size))
        case .custom(_, let path, let size):
            return try! register(name: name, path: path, size: Int32(size))
        }
    }

    public var count: Int {
        fonts.count
    }

    public func withFontArray<T>(_ body: (UnsafeMutablePointer<OpaquePointer?>?) -> T) -> T {
        fontArray.withUnsafeMutableBufferPointer { buffer in
            body(buffer.baseAddress)
        }
    }
}

import Foundation

// MARK: - ClayFont

public enum ClayFont: Sendable {
    case system(size: UInt16)
    case custom(name: String, path: String, size: UInt16)

    public init(size: UInt16) {
        self = .system(size: size)
    }

    var registerName: String {
        switch self {
        case .system(let size): return "ClayFont-\(size)"
        case .custom(let name, _, let size): return "\(name)-\(size)"
        }
    }

    var size: UInt16 {
        switch self {
        case .system(let size): return size
        case .custom(_, _, let size): return size
        }
    }
}

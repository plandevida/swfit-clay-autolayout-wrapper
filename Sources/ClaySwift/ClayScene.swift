import Foundation

// MARK: - ClayScene Protocol

@MainActor
public protocol ClayScene {
    func configure(fontRegistry: ClayFontRegistry)
}

// MARK: - WindowGroup

public struct WindowGroup: ClayScene {
    public let title: String
    public let width: Int32
    public let height: Int32
    private let content: () -> [any ClayView]

    public init(
        _ title: String,
        width: Int32 = 1200,
        height: Int32 = 800,
        @ClayViewBuilder content: @escaping () -> [any ClayView]
    ) {
        self.title = title
        self.width = width
        self.height = height
        self.content = content
    }

    public func configure(fontRegistry: ClayFontRegistry) {
        for view in content() {
            view.configure(fontRegistry: fontRegistry)
        }
    }
}

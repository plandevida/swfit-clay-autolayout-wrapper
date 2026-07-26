import ClaySwift

@main
struct BasicUI {
    static func main() throws {
        let window = try ClayWindow(title: "ClaySwift Basic UI", width: 1200, height: 800)

        let fontId = window.registerFont(name: "Regular", path: "/System/Library/Fonts/Helvetica.ttc", size: 16)
        _ = window.registerFont(name: "Bold", path: "/System/Library/Fonts/Helvetica.ttc", size: 24)

        var clickCount = 0
        let messages = ["Hello!", "Click me!", "Again!", "One more!", "Keep going!", "You did it!"]
        let buttonId = ClayID("click-button")

        do {
            try window.run {
                ClayElement("Root",
                    layout: ClayLayoutConfig(
                        sizing: .grow(),
                        padding: ClayPadding(16),
                        childGap: 16
                    )
                ) {
                    // Sidebar
                    ClayElement("Sidebar",
                        layout: ClayLayoutConfig(
                            sizing: ClaySizing(width: .fixed(250), height: .grow()),
                            padding: ClayPadding(12),
                            childGap: 8,
                            layoutDirection: .topToBottom
                        ),
                        backgroundColor: ClayColor(240, 240, 245),
                        cornerRadius: ClayCornerRadius(8)
                    ) {
                        ClayText("Menu", config: ClayTextConfig(
                            textColor: ClayColor(50, 50, 50),
                            fontId: fontId,
                            fontSize: 24
                        ))

                        for item in ["Home", "Settings", "About"] {
                            ClayElement("nav-\(item)",
                                layout: ClayLayoutConfig(
                                    sizing: .grow(),
                                    padding: ClayPadding(horizontal: 12, vertical: 8)
                                ),
                                backgroundColor: ClayColor(220, 220, 230),
                                cornerRadius: ClayCornerRadius(6)
                            ) {
                                ClayText(item, config: ClayTextConfig(
                                    textColor: ClayColor(80, 80, 80),
                                    fontId: fontId,
                                    fontSize: 16
                                ))
                            }
                        }
                    }

                    // Main content
                    ClayElement("Content",
                        layout: ClayLayoutConfig(
                            sizing: .grow(),
                            padding: ClayPadding(24),
                            childGap: 16,
                            layoutDirection: .topToBottom
                        ),
                        backgroundColor: .white,
                        cornerRadius: ClayCornerRadius(8)
                    ) {
                        ClayText("Welcome to ClaySwift", config: ClayTextConfig(
                            textColor: ClayColor(30, 30, 30),
                            fontId: fontId,
                            fontSize: 32
                        ))

                        ClayText("A Swift wrapper for the Clay UI layout library, powered by SDL3.", config: ClayTextConfig(
                            textColor: ClayColor(100, 100, 100),
                            fontId: fontId,
                            fontSize: 16
                        ))

                        // Click counter text field
                        ClayElement("counter-field",
                            layout: ClayLayoutConfig(
                                sizing: ClaySizing(width: .fixed(200), height: .fixed(40)),
                                padding: ClayPadding(horizontal: 12, vertical: 8),
                                childAlignment: .center
                            ),
                            backgroundColor: ClayColor(250, 250, 255),
                            cornerRadius: ClayCornerRadius(6),
                            border: ClayBorderConfig(1, color: ClayColor(200, 200, 210), cornerRadius: ClayCornerRadius(6))
                        ) {
                            ClayText("Clicked: \(clickCount) times", config: ClayTextConfig(
                                textColor: ClayColor(40, 40, 40),
                                fontId: fontId,
                                fontSize: 16
                            ))
                        }

                        // Click button
                        ClayElement("click-button",
                            layout: ClayLayoutConfig(
                                sizing: ClaySizing(width: .fixed(200), height: .fixed(50)),
                                padding: ClayPadding(horizontal: 16, vertical: 12),
                                childAlignment: .center
                            ),
                            backgroundColor: ClayColor(50, 120, 220),
                            cornerRadius: ClayCornerRadius(8)
                        ) {
                            ClayText(messages[clickCount % messages.count], config: ClayTextConfig(
                                textColor: .white,
                                fontId: fontId,
                                fontSize: 18
                            ))
                        }

                        // Cards
                        ClayElement("Cards",
                            layout: ClayLayoutConfig(
                                sizing: .grow(),
                                padding: ClayPadding(16),
                                childGap: 12
                            )
                        ) {
                            for i in 1...3 {
                                ClayElement("card-\(i)",
                                    layout: ClayLayoutConfig(
                                        sizing: .grow(),
                                        padding: ClayPadding(16)
                                    ),
                                    backgroundColor: ClayColor(245, 245, 250),
                                    cornerRadius: ClayCornerRadius(8),
                                    border: ClayBorderConfig(1, color: ClayColor(200, 200, 210), cornerRadius: ClayCornerRadius(8))
                                ) {
                                    ClayText("Card \(i)", config: ClayTextConfig(
                                        textColor: ClayColor(60, 60, 60),
                                        fontId: fontId,
                                        fontSize: 18
                                    ))
                                }
                            }
                        }
                    }
                }.configure()

                // Detect button click
                if window.input.mouseLeftReleased && window.pointerOver(buttonId) {
                    clickCount += 1
                }
            }
        } catch {
            print(error)
        }
    }
}

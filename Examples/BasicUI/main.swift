import ClaySwift

@main
final class BasicUI: ClayApp {
    @State private var clickCount = 0
    let messages = ["Hello!", "Click me!", "Again!", "One more!", "Keep going!", "You did it!"]
    let menus = ["Home", "Settings", "About", "somthing", "something 2", "something 3"]
    let colors = [
        ClayColor(UInt8.random(in: 1 ... 255),
                  UInt8.random(in: 1 ... 255),
                  UInt8.random(in: 1 ... 255)),
        ClayColor(UInt8.random(in: 1 ... 255),
                  UInt8.random(in: 1 ... 255),
                  UInt8.random(in: 1 ... 255)),
        ClayColor(UInt8.random(in: 1 ... 255),
                  UInt8.random(in: 1 ... 255),
                  UInt8.random(in: 1 ... 255)),
        ClayColor(UInt8.random(in: 1 ... 255),
                  UInt8.random(in: 1 ... 255),
                  UInt8.random(in: 1 ... 255)),
        ClayColor(UInt8.random(in: 1 ... 255),
                  UInt8.random(in: 1 ... 255),
                  UInt8.random(in: 1 ... 255)),
        ClayColor(UInt8.random(in: 1 ... 255),
                  UInt8.random(in: 1 ... 255),
                  UInt8.random(in: 1 ... 255)),
    ]

    required init() {}

    var body: some ClayScene {
        WindowGroup("ClaySwift Basic UI", width: 1200, height: 800) {
            HStack(spacing: 1) {
                // Sidebar
                VStack(spacing: 8) {
                    Text("Menu")
                        .font(.system(size: 48))
                        .frame(maxWidth: .infinity, alignment: .init(x: .left, y: .top))

                    ScrollView(.vertical) {
                        ForEach(self.menus, id: \.self) { item, index in
                            Text(item)
                                .font(.system(size: 24))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(height: 155, maxWidth: .infinity, alignment: .init(x: .left, y: .top))
                                .background(self.colors[index])
                                .cornerRadius(6)
                        }
                    }
                }
                .padding(12)
                .frame(width: 150)
                .background(ClayColor(240, 240, 245))
                .cornerRadius(8)

                // Main content
                VStack(alignment: .init(x: .left, y: .top), spacing: 16) {
                    Text("Welcome to ClaySwift")
                        .font(.system(size: 32))

                    Text("A Swift wrapper for the Clay UI layout library, powered by SDL3.")
                        .font(.system(size: 16))
                        .foregroundStyle(ClayColor(100, 100, 100))

                    Text("Clicked: \(self.clickCount) times")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(alignment: .init(x: .center, y: .center))
                        .background(ClayColor(250, 250, 255))
                        .cornerRadius(6)
                        .border(1, color: ClayColor(200, 200, 210))
                    // .frame(height: 40)

                    Button(self.messages[self.clickCount % self.messages.count]) {
                        self.clickCount += 1
                    }
                    .frame(width: 200, height: 50)

                    HStack(spacing: 12) {
                        ForEach(1 ... 3, id: \.self) { i, _ in
                            Text("Card \(i)")
                                .frame(height: 60, maxWidth: .infinity, alignment: .init(x: .left, y: .top))
                                .padding(16)
                                .background(ClayColor(245, 245, 250))
                                .cornerRadius(8)
                                .border(1, color: ClayColor(200, 200, 210))
                        }
                    }
                }
                .padding(24)
            }
            .padding(16)
        }
    }
}

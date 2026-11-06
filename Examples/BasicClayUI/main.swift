import ClaySwift

@main
final class BasicClayUI: ClayApp {
    @State private var clickCount = 0
    let messages = ["Hello!", "Click me!", "Again!", "One more!", "Keep going!", "You did it!"]

    required init() {}

    var body: some ClayScene {
        WindowGroup("ClaySwift Basic UI", width: 1200, height: 800) {
            HStack(spacing: 16) {
                // Sidebar
                VStack(spacing: 8) {
                    Text("Menu")
                        .font(.system(size: 24))
                        .frame(maxWidth: .infinity, alignment: .init(x: .left, y: .top))

                    ForEach(["Home", "Settings", "About"], id: \.self) { item, _ in
                        Text(item)
                            .font(.system(size: 16))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .init(x: .left, y: .top))
                            .background(ClayColor(220, 220, 230))
                            .cornerRadius(6)
                    }
                }
                .padding(12)
                .frame(width: 250)
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
                        .frame(width: 200, height: 40, alignment: .init(x: .left, y: .center))
                        .background(ClayColor(250, 250, 255))
                        .cornerRadius(6)
                        .border(1, color: ClayColor(200, 200, 210))

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

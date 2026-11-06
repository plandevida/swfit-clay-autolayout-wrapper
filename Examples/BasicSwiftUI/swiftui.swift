import SwiftUI

final class CounterModel: ObservableObject {
    @Published var clickCount = 0
}

@main
struct SwiftUIApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var model = CounterModel()
    let messages = ["Hello!", "Click me!", "Again!", "One more!", "Keep going!", "You did it!"]

    // init() {
    //     NSApp.setActivationPolicy(.regular)
    //     NSApp.activate(ignoringOtherApps: true)
    //     NSApp.windows.first?.makeKeyAndOrderFront(nil)
    // }

    var body: some Scene {
        WindowGroup("ClaySwift Basic UI") {
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Menu")
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(["Home", "Settings", "About"], id: \.self) { item in
                        Text(item)
                            .font(.system(size: 16))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(white: 0.87))
                            .cornerRadius(6)
                    }
                }
                .padding(12)
                .frame(width: 250)
                .background(Color(white: 0.94))
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Welcome to ClaySwift")
                        .font(.system(size: 32))
                    Text("A Swift wrapper for the Clay UI layout library, powered by SDL3.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)

                    Text("Clicked: \(model.clickCount) times")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(width: 200, height: 40, alignment: .leading)
                        .background(Color(white: 0.98))
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(white: 0.82)))

                    Button(messages[model.clickCount % messages.count]) {
                        model.clickCount += 1
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(width: 200, height: 50)

                    HStack(spacing: 12) {
                        ForEach(1 ... 3, id: \.self) { i in
                            Text("Card \(i)")
                                .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                                .padding(16)
                                .background(Color(white: 0.96))
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(white: 0.82)))
                        }
                    }
                }
                .padding(24)
            }
            .padding(16)
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_: Notification) {
        print("[DEBUG] applicationWillFinishLaunching called")
        NSApp.setActivationPolicy(.regular)
    }

    func applicationDidFinishLaunching(_: Notification) {
        print("[DEBUG] applicationDidFinishLaunching called")
        NSApp.activate(ignoringOtherApps: true)
    }
}

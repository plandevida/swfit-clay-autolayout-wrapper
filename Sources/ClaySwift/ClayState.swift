import Foundation

// MARK: - @State

@MainActor
@propertyWrapper
public struct State<Value>: DynamicProperty {
    public let id: String
    private let defaultValue: Value

    public init(wrappedValue value: Value) {
        self.id = UUID().uuidString
        self.defaultValue = value
    }

    public var wrappedValue: Value {
        get { ClayAppRuntime.current?.stateValue(for: id) as? Value ?? defaultValue }
        set { ClayAppRuntime.current?.setStateValue(for: id, value: newValue) }
    }

    public var projectedValue: StateBinding<Value> {
        StateBinding(id: id, defaultValue: defaultValue)
    }

    public func update() {}
}

// MARK: - StateBinding

@MainActor
public struct StateBinding<Value> {
    let id: String
    let defaultValue: Value

    public var wrappedValue: Value {
        get { ClayAppRuntime.current?.stateValue(for: id) as? Value ?? defaultValue }
        nonmutating set { ClayAppRuntime.current?.setStateValue(for: id, value: newValue) }
    }
}

// MARK: - DynamicProperty

@MainActor
public protocol DynamicProperty {
    func update()
}

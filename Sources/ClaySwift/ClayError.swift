import CClay

// MARK: - ClayError

public enum ClayErrorType: Sendable {
    case textMeasurementFunctionNotProvided
    case arenaCapacityExceeded
    case elementsCapacityExceeded
    case textMeasurementCapacityExceeded
    case duplicateId
    case floatingContainerParentNotFound
    case percentageOver1
    case internalError
    case unbalancedOpenClose
    case hashMapCapacityExceeded
    case unknown(UInt32)

    internal init(from cType: Clay_ErrorType) {
        switch cType {
        case CLAY_ERROR_TYPE_TEXT_MEASUREMENT_FUNCTION_NOT_PROVIDED: self = .textMeasurementFunctionNotProvided
        case CLAY_ERROR_TYPE_ARENA_CAPACITY_EXCEEDED: self = .arenaCapacityExceeded
        case CLAY_ERROR_TYPE_ELEMENTS_CAPACITY_EXCEEDED: self = .elementsCapacityExceeded
        case CLAY_ERROR_TYPE_TEXT_MEASUREMENT_CAPACITY_EXCEEDED: self = .textMeasurementCapacityExceeded
        case CLAY_ERROR_TYPE_DUPLICATE_ID: self = .duplicateId
        case CLAY_ERROR_TYPE_FLOATING_CONTAINER_PARENT_NOT_FOUND: self = .floatingContainerParentNotFound
        case CLAY_ERROR_TYPE_PERCENTAGE_OVER_1: self = .percentageOver1
        case CLAY_ERROR_TYPE_INTERNAL_ERROR: self = .internalError
        case CLAY_ERROR_TYPE_UNBALANCED_OPEN_CLOSE: self = .unbalancedOpenClose
        case CLAY_ERROR_TYPE_HASH_MAP_CAPACITY_EXCEEDED: self = .hashMapCapacityExceeded
        default: self = .unknown(UInt32(cType.rawValue))
        }
    }
}

public struct ClayError: Error, CustomStringConvertible {
    public let type: ClayErrorType
    public let message: String

    public var description: String {
        "[Clay Error] \(type): \(message)"
    }
}

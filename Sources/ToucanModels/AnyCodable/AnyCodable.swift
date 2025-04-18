public struct AnyCodable: Codable {

    public var value: Any?

    public init<T>(_ value: T?) {
        self.value = value
    }

    public func value<T>(as: T.Type) -> T? {
        value as? T
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case nil:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any?]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any?]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        case let encodable as Encodable:
            try encodable.encode(to: encoder)
        default:
            let context = EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "AnyCodable value cannot be encoded"
            )
            throw EncodingError.invalidValue(value!, context)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.init(Optional<Self>.none)
        }
        else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        }
        else if let int = try? container.decode(Int.self) {
            self.init(int)
        }
        else if let double = try? container.decode(Double.self) {
            self.init(double)
        }
        else if let string = try? container.decode(String.self) {
            self.init(string)
        }
        else if let array = try? container.decode([AnyCodable].self) {
            self.init(array.map { $0.value })
        }
        else if let dictionary = try? container.decode(
            [String: AnyCodable].self
        ) {
            self.init(dictionary.mapValues { wrap($0) })
        }
        else {
            print("throw DecodingError.dataCorruptedError")
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable value cannot be decoded"
            )
        }
    }
}

public extension AnyCodable {

    func boolValue() -> Bool? {
        value(as: Bool.self)
    }

    func intValue() -> Int? {
        value(as: Int.self)
    }

    func doubleValue() -> Double? {
        value(as: Double.self)
    }

    func stringValue() -> String? {
        value(as: String.self)
    }

    func arrayValue<T>(as type: T.Type) -> [T] {
        value(as: [T].self) ?? []
    }

    func dictValue() -> [String: AnyCodable] {
        value(as: [String: AnyCodable].self) ?? [:]
    }
}

extension AnyCodable: Equatable {

    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case (nil, nil):
            return true
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as [String: AnyCodable], rhs as [String: AnyCodable]):
            return lhs == rhs
        case let (lhs as [AnyCodable], rhs as [AnyCodable]):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension AnyCodable: CustomStringConvertible {

    public var description: String {
        switch value {
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value)
        }
    }
}

extension AnyCodable: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch value {
        case let value as CustomDebugStringConvertible:
            return "AnyCodable(\(value.debugDescription))"
        default:
            return "AnyCodable(\(description))"
        }
    }
}

extension AnyCodable: ExpressibleByNilLiteral {
    public init(nilLiteral _: ()) {
        self.init(nil as Any?)
    }
}

extension AnyCodable: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByStringLiteral {
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}

extension AnyCodable: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (AnyHashable, Any)...) {
        var dict: [String: AnyCodable] = [:]
        for (key, value) in elements {
            let converted: AnyCodable
            if let childDict = value as? [AnyHashable: Any] {
                var newDict: [String: AnyCodable] = [:]
                for (childKey, childValue) in childDict {
                    newDict[String(describing: childKey)] = AnyCodable(
                        childValue
                    )
                }
                converted = AnyCodable(newDict)
            }
            else if let arrayValue = value as? [Any] {
                let newArray = arrayValue.map { element -> AnyCodable in
                    if let dictElement = element as? [AnyHashable: Any] {
                        var newDict: [String: AnyCodable] = [:]
                        for (childKey, childValue) in dictElement {
                            newDict[String(describing: childKey)] = AnyCodable(
                                childValue
                            )
                        }
                        return AnyCodable(newDict)
                    }
                    return AnyCodable(element)
                }
                converted = AnyCodable(newArray)
            }
            else {
                converted = AnyCodable(value)
            }
            dict[String(describing: key)] = converted
        }
        self.init(dict)
    }
}

extension AnyCodable: Hashable {

    public func hash(into hasher: inout Hasher) {
        switch value {
        case let value as Bool:
            hasher.combine(value)
        case let value as Int:
            hasher.combine(value)
        case let value as Double:
            hasher.combine(value)
        case let value as String:
            hasher.combine(value)
        case let value as [String: AnyCodable]:
            hasher.combine(value)
        case let value as [AnyCodable]:
            hasher.combine(value)
        default:
            break
        }
    }
}

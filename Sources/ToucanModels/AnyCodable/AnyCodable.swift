import Foundation

/// A type-erased wrapper for any `Codable` value, allowing serialization of
/// heterogeneous data structures (e.g., JSON-like dictionaries or YAML trees).
///
/// Supports dynamic type resolution during encoding/decoding,
/// literal initialization, value extraction, and hashing.
public struct AnyCodable: Codable {

    /// The wrapped value (may be `nil`, scalar, array, dictionary, etc.).
    public var value: Any?

    // MARK: - Initialization

    /// Initializes with any optional value.
    public init<T>(_ value: T?) {
        self.value = value
    }

    // MARK: - Typed Value Access

    /// Attempts to cast the internal value to a concrete type.
    ///
    /// - Parameter type: The target type.
    /// - Returns: The casted value, or `nil` if the cast fails.
    public func value<T>(as type: T.Type) -> T? {
        value as? T
    }

    // MARK: - Encoding

    /// Encodes the wrapped value using the provided encoder.
    ///
    /// Supports scalars, arrays, dictionaries, and any `Encodable` object.
    /// Throws an error for unsupported types.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: `EncodingError.invalidValue` if the value cannot be encoded.
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
            throw EncodingError.invalidValue(
                value!,
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "AnyCodable value cannot be encoded"
                )
            )
        }
    }

    // MARK: - Decoding

    /// Decodes a value from the given decoder and stores it in a type-erased wrapper.
    ///
    /// Automatically handles null, scalars, arrays, and dictionaries.
    ///
    /// - Parameter decoder: The decoder providing the data.
    /// - Throws: `DecodingError.dataCorruptedError` if the value cannot be decoded.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.init(nil as Any?)
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
            self.init(dictionary.mapValues { $0 })
        }
        else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable value cannot be decoded"
            )
        }
    }
}

public extension AnyCodable {
    func boolValue() -> Bool? { value(as: Bool.self) }
    func intValue() -> Int? { value(as: Int.self) }
    func doubleValue() -> Double? { value(as: Double.self) }
    func stringValue() -> String? { value(as: String.self) }
    func arrayValue<T>(as type: T.Type) -> [T] { value(as: [T].self) ?? [] }
    func dictValue() -> [String: AnyCodable] {
        value(as: [String: AnyCodable].self) ?? [:]
    }
}

extension AnyCodable: Equatable {

    /// Compares two `AnyCodable` values for equality, including nested structures.
    ///
    /// Only compares supported primitive and collection types (Bool, Int, Double, String,
    /// arrays, and dictionaries). Other types will return `false`.
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

    /// Returns a human-readable description of the wrapped value.
    ///
    /// Falls back to `String(describing:)` if the value does not conform to `CustomStringConvertible`.
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

    /// Returns a debug-friendly string representation of the wrapped value.
    ///
    /// Prefixes the output with `"AnyCodable(...)"` for easy identification.
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
    /// Initializes an `AnyCodable` with `nil`.
    public init(nilLiteral _: ()) {
        self.init(nil as Any?)
    }
}

extension AnyCodable: ExpressibleByBooleanLiteral {
    /// Initializes an `AnyCodable` with a boolean literal.
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByIntegerLiteral {
    /// Initializes an `AnyCodable` with an integer literal.
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByFloatLiteral {
    /// Initializes an `AnyCodable` with a floating-point literal.
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByStringLiteral {
    /// Initializes an `AnyCodable` with a string literal.
    public init(stringLiteral value: String) {
        self.init(value)
    }

    /// Required for extended grapheme cluster literals.
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}

extension AnyCodable: ExpressibleByStringInterpolation {}

extension AnyCodable: ExpressibleByArrayLiteral {
    /// Initializes an `AnyCodable` with an array literal.
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}

extension AnyCodable: ExpressibleByDictionaryLiteral {

    /// Initializes an `AnyCodable` with a dictionary literal.
    ///
    /// Also recursively wraps nested dictionaries and arrays.
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

    /// Computes a hash based on the value type.
    ///
    /// Only values of supported types will be hashed.
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
            break  // Non-hashable values are ignored
        }
    }
}

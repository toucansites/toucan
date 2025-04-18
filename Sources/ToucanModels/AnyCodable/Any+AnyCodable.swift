//
//  Any+AnyCodable.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 03. 06..
//

/// Recursively unwraps a value that may contain `AnyCodable` types into native Swift types.
///
/// - Parameter value: A possibly wrapped `Any?`, including `[String: AnyCodable]`, `[AnyCodable]`, etc.
/// - Returns: A fully unwrapped `Any?`, preserving dictionaries and arrays but removing all `AnyCodable` wrappers.
public func unwrap(_ value: Any?) -> Any? {
    if let anyCodable = value as? AnyCodable {
        return unwrap(anyCodable.value)
    }
    if let dict = value as? [String: AnyCodable] {
        var result: [String: Any] = [:]
        for (key, val) in dict {
            result[key] = unwrap(val)
        }
        return result
    }
    if let dict = value as? [String: Any] {
        var result: [String: Any] = [:]
        for (key, val) in dict {
            result[key] = unwrap(val)
        }
        return result
    }
    if let array = value as? [Any] {
        return array.map { unwrap($0) }
    }
    return value
}

/// Recursively wraps a native Swift value into an `AnyCodable` structure,
/// enabling flexible serialization and dynamic schema support.
///
/// - Parameter value: A raw value of any supported type (`Int`, `Bool`, `String`, array, dictionary, etc.).
/// - Returns: A wrapped `AnyCodable` version of the input, preserving nested structure.
public func wrap(_ value: Any?) -> AnyCodable {
    if let anyCodable = value as? AnyCodable {
        return anyCodable
    }
    if let dict = value as? [String: AnyCodable] {
        var result: [String: AnyCodable] = [:]
        for (key, val) in dict {
            result[key] = wrap(val)
        }
        return AnyCodable(result)
    }
    if let dict = value as? [String: Any] {
        var result: [String: AnyCodable] = [:]
        for (key, val) in dict {
            result[key] = wrap(val)
        }
        return AnyCodable(result)
    }
    if let array = value as? [Any] {
        return AnyCodable(array.map { wrap($0) })
    }
    return AnyCodable(value)
}

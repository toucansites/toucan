//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 03. 06..
//

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

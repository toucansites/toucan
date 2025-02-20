import Foundation

extension Dictionary where Key == String, Value == Any {

    func sanitized() -> [String: Any] {
        var result: [String: Any] = [:]

        for (key, value) in self {
            if let nestedDict = value as? [String: Any] {
                result[key] = nestedDict.sanitized()
            }
            else if let arrayValue = value as? [Any] {
                result[key] = arrayValue.sanitized()
            }
            else if let anyHashableValue = value as? AnyHashable {
                result[key] = anyHashableValue.base
            }
            else {
                result[key] = value
            }
        }
        return result
    }
}

extension Array where Element == Any {

    func sanitized() -> [Any] {
        map { element in
            if let nestedDict = element as? [String: Any] {
                return nestedDict.sanitized()
            }
            if let anyHashableValue = element as? AnyHashable {
                return anyHashableValue.base
            }
            if let arrayValue = element as? [Any] {
                return arrayValue.sanitized()
            }
            return element
        }
    }
}

/// This extension allows recursive merging of dictionaries with String keys and Any values.
extension Dictionary where Key == String, Value == Any {

    /// Recursively merges another `[String: Any]` dictionary into the current dictionary and returns a new dictionary.
    ///
    /// - Parameter other: The dictionary to merge into the current dictionary.
    /// - Returns: A new dictionary with the merged contents.
    func recursivelyMerged(with other: [String: Any]) -> [String: Any] {
        var result = self
        for (key, value) in other {
            if let existingValue = result[key] as? [String: Any],
                let newValue = value as? [String: Any]
            {
                result[key] = existingValue.recursivelyMerged(with: newValue)
            }
            else {
                result[key] = value
            }
        }
        return result
    }
}

public extension Dictionary {

    /// Same values, corresponding to `map`ped keys.
    ///
    /// - Parameter transform: Accepts each key of the dictionary as its parameter
    ///   and returns a key for the new dictionary.
    /// - Postcondition: The collection of transformed keys must not contain duplicates.
    func mapKeys<Transformed>(
        _ transform: (Key) throws -> Transformed
    ) rethrows -> [Transformed: Value] {
        .init(
            uniqueKeysWithValues: try map { (try transform($0.key), $0.value) }
        )
    }

    /// Same values, corresponding to `map`ped keys.
    ///
    /// - Parameters:
    ///   - transform: Accepts each key of the dictionary as its parameter
    ///     and returns a key for the new dictionary.
    ///   - combine: A closure that is called with the values for any duplicate
    ///     keys that are encountered. The closure returns the desired value for
    ///     the final dictionary.
    func mapKeys<Transformed>(
        _ transform: (Key) throws -> Transformed,
        uniquingKeysWith combine: (Value, Value) throws -> Value
    ) rethrows -> [Transformed: Value] {
        try .init(
            map { (try transform($0.key), $0.value) },
            uniquingKeysWith: combine
        )
    }

    /// `compactMap`ped keys, with their values.
    ///
    /// - Parameter transform: Accepts each key of the dictionary as its parameter
    ///   and returns a potential key for the new dictionary.
    /// - Postcondition: The collection of transformed keys must not contain duplicates.
    func compactMapKeys<Transformed>(
        _ transform: (Key) throws -> Transformed?
    ) rethrows -> [Transformed: Value] {
        .init(
            uniqueKeysWithValues: try compactMap { key, value in
                try transform(key).map { ($0, value) }
            }
        )
    }
}

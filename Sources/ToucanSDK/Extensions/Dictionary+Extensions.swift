import Foundation

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

/// An extension for `Dictionary` where the keys are `String` and the values are `Any`, providing utility methods to fetch values with specific types and key paths.
extension Dictionary where Key == String, Value == Any {

    /// Retrieves the value associated with the given key path and casts it to the specified type.
    ///
    /// - Parameters:
    ///   - keyPath: The key path string, where keys are separated by dots.
    ///   - type: The type to cast the value to.
    /// - Returns: The value cast to the specified type, or `nil` if the key path is invalid or the value cannot be cast.
    func value<T>(_ keyPath: String, as type: T.Type) -> T? {
        let keys = keyPath.split(separator: ".").map { String($0) }

        guard !keys.isEmpty else {
            return nil
        }
        var currentDict: [String: Any] = self

        for key in keys.dropLast() {
            if let dict = currentDict[key] as? [String: Any] {
                currentDict = dict
            }
            else {
                return nil
            }
        }
        return currentDict[keys.last!] as? T
    }

    /// Retrieves the dictionary associated with the given key path.
    ///
    /// - Parameter keyPath: The key path string, where keys are separated by dots.
    /// - Returns: The dictionary at the specified key path, or an empty dictionary if the key path is invalid.
    func dict(_ keyPath: String) -> [String: Any] {
        value(keyPath, as: [String: Any].self) ?? [:]
    }

    /// Retrieves the string associated with the given key path.
    ///
    /// - Parameter keyPath: The key path string, where keys are separated by dots.
    /// - Returns: The string at the specified key path
    func string(_ keyPath: String) -> String? {
        value(keyPath, as: String.self)
    }

    /// Retrieves the integer associated with the given key path.
    ///
    /// - Parameter keyPath: The key path string, where keys are separated by dots.
    /// - Returns: The integer at the specified key path, or `nil` if the key path is invalid.
    func int(_ keyPath: String) -> Int? {
        value(keyPath, as: Int.self)
    }
}

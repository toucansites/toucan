//
//  Dictionary+Extensions.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 03..
//

public extension Dictionary {

    /// Transforms the keys of the dictionary using the given closure, preserving the associated values.
    ///
    /// This method applies the provided transformation to each key in the dictionary,
    /// resulting in a new dictionary with the transformed keys and original values.
    ///
    /// - Parameter t: A closure that takes a key as input and returns a transformed key.
    /// - Returns: A dictionary with transformed keys and the original values.
    func mapKeys<T>(
        _ t: (Key) throws -> T
    ) rethrows -> [T: Value] {
        .init(
            uniqueKeysWithValues: try map { (try t($0.key), $0.value) }
        )
    }
}

/// This extension allows recursive merging of dictionaries with String keys and Any values.
public extension Dictionary where Key == String {

    /// Recursively merges another `[String: Value]` dictionary into the current dictionary and returns a new dictionary.
    ///
    /// - Parameter other: The dictionary to merge into the current dictionary.
    /// - Returns: A new dictionary with the merged contents.
    func recursivelyMerged(
        with other: [String: Value]
    ) -> [String: Value] {
        var result = self
        for (key, value) in other {
            if let existingValue = result[key] as? [String: Value],
                let newValue = value as? [String: Value]
            {
                result[key] =
                    existingValue.recursivelyMerged(with: newValue) as? Value
            }
            else {
                result[key] = value
            }
        }
        return result
    }

    /// Retrieves a nested value from the receiver using a dot-separated key path.
    /// Supports traversal through dictionaries with `String` keys and arrays with numeric indices.
    ///
    /// - Parameter keyPath: A dot-separated string representing the path to the nested value.
    /// - Returns: The value at the specified key path, or `nil` if the path is invalid.
    func value(
        forKeyPath keyPath: String
    ) -> Any? {
        let keys = keyPath.split(separator: ".").map(String.init)
        var current: Any? = self

        for key in keys {
            if let dict = current as? [String: Any], let next = dict[key] {
                current = next
                continue
            }

            if let array = current as? [Any], let index = Int(key),
                array.indices.contains(index)
            {
                current = array[index]
                continue
            }

            return nil
        }

        return current
    }
}

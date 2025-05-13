//
//  Dictionary+KeyPath.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 11..
//

public extension [String: Any] {

    /// Retrieves a nested value from the receiver using a dot-separated key path.
    /// Supports traversal through dictionaries with `String` keys and arrays with numeric indices.
    ///
    /// - Parameter keyPath: A dot-separated string representing the path to the nested value.
    /// - Returns: The value at the specified key path, or `nil` if the path is invalid.
    func value(forKeyPath keyPath: String) -> Any? {
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

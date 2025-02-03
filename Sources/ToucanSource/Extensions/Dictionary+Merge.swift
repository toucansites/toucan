//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

/// This extension allows recursive merging of dictionaries with String keys and Any values.
extension Dictionary where Key == String {

    /// Recursively merges another `[String: Any]` dictionary into the current dictionary and returns a new dictionary.
    ///
    /// - Parameter other: The dictionary to merge into the current dictionary.
    /// - Returns: A new dictionary with the merged contents.
    func recursivelyMerged(with other: [String: Value]) -> [String: Value] {
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
}

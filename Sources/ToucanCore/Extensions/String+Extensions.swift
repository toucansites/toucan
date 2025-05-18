//
//  String+Extensions.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 17..
//

public extension String {

    /// A convenience property that converts an empty string to `nil`.
    ///
    /// This is useful for cases where an empty string should be treated as the absence of a value,
    /// such as when preparing optional fields for encoding, form validation, or API payloads.
    ///
    /// For example:
    /// ```swift
    /// let name: String = ""
    /// let optionalName = name.emptyToNil // Result: nil
    /// ```
    ///
    /// - Returns: `nil` if the string is empty; otherwise, returns the original string.
    var emptyToNil: String? {
        isEmpty ? nil : self
    }
}

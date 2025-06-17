//
//  Path.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 04..
//

import Foundation

/// A value type representing a path for a raw content item.
public struct Path: Equatable {
    // MARK: - Properties

    /// The raw value as a string.
    public var value: String

    // MARK: - Lifecycle

    /// Initializes a new path.
    ///
    /// - Parameter value: The raw path value string.
    public init(
        _ value: String
    ) {
        self.value = value
    }
}

extension Path: Codable {
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer attempts to decode the value as a single string.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if reading from the decoder fails, or if the data is not a single string.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(String.self)
    }

    /// Encodes this value into the given encoder.
    ///
    /// This method encodes the value as a single string.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if encoding fails.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

public extension Path {
    /// Returns a new `Path` instance with the last component removed.
    ///
    /// Useful for extracting the base directory of a given path.
    ///
    /// - Returns: A `Path` instance without the final path component.
    func basePath() -> Path {
        let rawPath =
            value
            .split(separator: "/")
            .dropLast()
            .joined(separator: "/")

        return .init(rawPath)
    }

    /// Returns a string with all content inside brackets removed.
    ///
    /// Optionally removes percent encoding before processing.
    ///
    /// - Parameter shouldRemovePercentEncoding: A Boolean value that indicates whether to remove percent encoding.
    /// - Returns: A string without the content inside square brackets.
    func trimmingBracketsContent(
        shouldRemovePercentEncoding: Bool = true
    ) -> String {
        var result = ""
        var insideBrackets = false

        let finalValue =
            if shouldRemovePercentEncoding {
                value.removingPercentEncoding ?? value
            }
            else {
                value
            }

        for char in finalValue {
            if char == "[" {
                insideBrackets = true
            }
            else if char == "]" {
                insideBrackets = false
            }
            else if !insideBrackets {
                result.append(char)
            }
        }
        return result
    }
}

//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 11..
//

import Foundation

/// A protocol that defines a method for parsing table of contents elements from a string value.
protocol ToCElementParser {

    /// Parses the given string value into an array of `TocElement` objects.
    ///
    /// - Parameter value: The string representation of the table of contents elements.
    /// - Returns: An array of `TocElement` objects if parsing is successful, or `nil` if parsing fails.
    func parse(from value: String) -> [TocElement]?
}

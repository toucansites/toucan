//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 14..
//

import Foundation

/// Represents an element in a table of contents.
///
/// - Parameters:
///   - level: The level of the heading.
///   - text: The display text of the element.
///   - fragment: The fragment identifier for the element's link.
struct TocElement {
    let level: Int
    let text: String
    let fragment: String
}

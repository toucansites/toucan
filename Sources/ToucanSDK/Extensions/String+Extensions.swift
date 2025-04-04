//
//  String+Extensions.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 12..
//

import Foundation

extension String {


    /// Removes the front matter from a string if it starts with a "---" delimiter.
    ///
    /// This method checks if the string starts with the "---" delimiter. If it does, it splits the string
    /// at each occurrence of the "---" delimiter, removes the first part (considered as front matter),
    /// and joins the remaining parts back together using the "---" delimiter. If the string does not
    /// start with the "---" delimiter, the original string is returned unchanged.
    ///
    /// - Returns: A new string with the front matter removed if it exists; otherwise, the original string.
    ///
    /// - Example:
    /// ```swift
    /// let text = """
    /// ---
    /// title: Example
    /// ---
    /// Content goes here.
    /// """
    /// let result = text.dropFrontMatter()
    /// "\nContent goes here."
    /// ```
    func dropFrontMatter() -> String {
        if starts(with: "---") {
            return
                self
                .split(separator: "---")
                .dropFirst()
                .joined(separator: "---")
        }
        return self
    }

}

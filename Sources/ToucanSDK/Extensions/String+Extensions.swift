//
//  String+Extensions.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 14..
//

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

    func trimmingBracketsContent() -> String {
        var result = ""
        var insideBrackets = false

        let decoded = self.removingPercentEncoding ?? self

        for char in decoded {
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

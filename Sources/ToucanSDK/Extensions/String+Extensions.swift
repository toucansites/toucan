import Foundation

extension String {

    var minifiedCss: String {
        var css = self
        let patterns = [
            "\n": "",
            "\\s+": " ",
            "\\s*:\\s*": ":",
            "\\s*\\,\\s*": ",",
            "\\s*\\{\\s": "{",
            "\\s*\\}\\s*": "}",
            "\\s*\\;\\s*": ";",
            "\\{\\s*": "{",
        ]

        for pattern in patterns {
            let regex = try! NSRegularExpression(
                pattern: pattern.key,
                options: .caseInsensitive
            )
            let range = NSRange(css.startIndex..., in: css)
            css = regex.stringByReplacingMatches(
                in: css,
                options: [],
                range: range,
                withTemplate: pattern.value
            )
        }
        return css
    }

    /// Generates a safe slug for the string, optionally with a given prefix.
    ///
    /// This method transforms the string into a "slug" format, handling special cases and
    /// optional prefixes. If the string is "home", it returns an empty string. If no prefix
    /// is provided or the prefix is empty, it returns the string itself transformed into
    /// a slug. If a prefix is provided, it appends the prefix to the slug.
    ///
    /// - Parameter:
    ///   - prefix: An optional prefix to prepend to the slug. If `nil` or empty, the prefix is ignored.
    /// - Returns: A slug version of the string, optionally prefixed.
    ///
    /// - Example:
    /// ```swift
    /// let text1 = "home"
    /// let result1 = text1.safeSlug(prefix: nil)
    /// ""
    ///
    /// let text2 = "about/us"
    /// let result2 = text2.safeSlug(prefix: nil)
    /// "about/us"
    ///
    /// let text3 = "contact"
    /// let result3 = text3.safeSlug(prefix: "pages")
    /// "pages/contact"
    ///
    /// let text4 = "contact"
    /// let result4 = text4.safeSlug(prefix: nil)
    /// "contact"
    /// ```
    func safeSlug(
        prefix: String?
    ) -> String {
        /// if it is empty then simply return
        guard !isEmpty else {
            return self
        }
        /// if there's no prefix, return the safe slug
        guard let prefix, !prefix.isEmpty else {
            return split(separator: "/").joined(separator: "/")
        }
        /// if there's a prefix, append it and return the safe slug
        return (prefix.split(separator: "/") + split(separator: "/"))
            .joined(separator: "/")
    }

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

    ///
    /// This method searches for the first occurrence of the `from` delimiter and the `to` delimiter,
    /// and returns the substring that is found between these two delimiters. If either delimiter is not found,
    /// the method returns `nil`.
    ///
    /// - Parameters:
    ///   - from: The starting delimiter. The method will look for the substring after this delimiter.
    ///   - to: The ending delimiter. The method will look for the substring before this delimiter.
    /// - Returns: An optional `String` containing the substring between the `from` and `to` delimiters, or `nil` if the delimiters are not found.
    ///
    /// - Example:
    /// ```swift
    /// let text = "Hello [world]!"
    /// if let result = text.slice(from: "[", to: "]") {
    ///     world
    /// }
    /// ```
    func slice(
        from: String,
        to: String
    ) -> String? {
        guard
            let fromIndex = range(of: from)?.upperBound,
            let toIndex = self[fromIndex...].range(of: to)?.lowerBound
        else {
            return nil
        }
        return String(self[fromIndex..<toIndex])
    }

    /// Checks if the string contains a "yyyy-mm-dd-" date prefix.
    ///
    /// This method checks if the string starts with a date in the "yyyy-mm-dd-" format.
    /// It validates the year, month, and day components to ensure they are numeric
    /// and have the appropriate lengths.
    ///
    /// - Returns: A boolean value indicating whether the string starts with the specified date prefix.
    ///
    /// - Example:
    /// ```
    /// let testString1 = "2023-06-13-example"
    /// let testString2 = "13-06-2023-example"
    ///
    /// testString1.hasDatePrefix() // true
    /// testString2.hasDatePrefix() // false
    /// ```
    func hasDatePrefix() -> Bool {
        /// Length of "yyyy-mm-dd-"
        let prefixLength = 11
        guard count >= prefixLength else {
            return false
        }
        let datePart = prefix(prefixLength)
        guard datePart.hasSuffix("-") else {
            return false
        }
        let dateComponents = datePart.split(separator: "-")
        guard dateComponents.count == 3 else {
            return false
        }
        /// use better component variable names
        let year = dateComponents[0]
        let month = dateComponents[1]
        let day = dateComponents[2]

        /// check all the component lenghts
        guard
            year.count == 4,
            month.count == 2,
            day.count == 2
        else {
            return false
        }
        /// check if all the components are numbers
        guard
            year.allSatisfy({ $0.isNumber }),
            month.allSatisfy({ $0.isNumber }),
            day.allSatisfy({ $0.isNumber })
        else {
            return false
        }
        return true
    }

    /// Returns a new string with everything after the last occurrence of the specified character dropped.
    ///
    /// - Parameter character: The character after which everything should be dropped.
    /// - Returns: A new string with the substring up to the last occurrence of the character.
    ///
    /// This extension method drops everything after the last occurrence of the specified character.
    func droppingEverythingAfterLastOccurrence(
        of character: Character
    ) -> String {
        guard let lastIndex = self.lastIndex(of: character) else {
            // If the character is not found, return the original string
            return self
        }
        let substring = self[..<lastIndex]
        return String(substring)
    }

    func slugify() -> String {
        let allowed = CharacterSet(
            charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-_."
        )
        return trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .folding(
                options: .diacriticInsensitive,
                locale: .init(identifier: "en_US")
            )
            .components(separatedBy: allowed.inverted)
            .filter { $0 != "" }
            .joined(separator: "-")
    }

    func replacingOccurrences(
        _ dictionary: [String: String]
    ) -> String {
        var result = self
        for (key, value) in dictionary {
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result
    }

    func permalink(
        baseUrl: String
    ) -> String {
        let components = split(separator: "/").map(String.init)
        if components.isEmpty {
            return baseUrl
        }
        if components.last?.split(separator: ".").count ?? 0 > 1 {
            return ([baseUrl] + components).joined(separator: "/")
        }
        return ([baseUrl] + components).joined(separator: "/") + "/"
    }

    func dropTrailingSlash() -> String {
        if hasSuffix("/") {
            return String(dropLast())
        }
        return self
    }
}

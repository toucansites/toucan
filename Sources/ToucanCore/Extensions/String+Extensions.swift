//
//  String+Extensions.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 17..
//

import Foundation

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

    /// Removes the leading slash from the string if present.
    ///
    /// This method checks if the string starts with a slash (`/`). If so, it removes it.
    ///
    /// - Returns: A new string without a leading slash, or the original string if no leading slash exists.
    func dropLeadingSlash() -> String {
        if hasPrefix("/") {
            return String(dropFirst())
        }
        return self
    }

    /// Removes the trailing slash from the string if present.
    ///
    /// This method checks if the string ends with a slash (`/`). If so, it removes it.
    ///
    /// - Returns: A new string without a trailing slash, or the original string if no trailing slash exists.
    func dropTrailingSlash() -> String {
        if hasSuffix("/") {
            return String(dropLast())
        }
        return self
    }

    /// Ensures the string starts with a leading slash.
    ///
    /// This method checks if the string already begins with a slash (`/`). If it does, the original string is returned.
    /// Otherwise, it prepends a slash to the beginning of the string.
    ///
    /// - Returns: A new string with a leading slash ensured.
    func ensureLeadingSlash() -> String {
        if hasPrefix("/") {
            return self
        }
        return "/" + self
    }

    /// Appends a trailing slash to the string if not already present.
    ///
    /// This method checks if the string ends with a slash (`/`). If not, it appends one.
    ///
    /// - Returns: A new string with a trailing slash ensured.
    func ensureTrailingSlash() -> String {
        if hasSuffix("/") {
            return self
        }
        return self + "/"
    }

    /// Replaces substrings in the string using a given dictionary of replacements.
    ///
    /// This method iterates over the key-value pairs in the provided dictionary
    /// and replaces all occurrences of each key with its corresponding value.
    ///
    /// - Parameter dictionary: A dictionary where each key is a substring to search for,
    ///   and the corresponding value is the string to replace it with.
    /// - Returns: A new string with all specified substrings replaced.
    func replacingOccurrences(
        _ dictionary: [String: String]
    ) -> String {
        var result = self
        for (key, value) in dictionary {
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result
    }

    /// Converts the string into a URL-friendly slug.
    ///
    /// This method removes diacritics, trims whitespace, lowercases the string,
    /// and keeps only alphanumeric characters, dashes, underscores, and periods.
    /// Invalid characters are removed, and remaining components are joined with hyphens.
    ///
    /// - Returns: A slugified version of the original string.
    func slugify() -> String {
        let allowed = CharacterSet(
            charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-_."
        )
        return trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .folding(
                options: .diacriticInsensitive,
                locale: .init(identifier: "en-US")
            )
            .components(separatedBy: allowed.inverted)
            .filter { $0 != "" }
            .joined(separator: "-")
    }

    /// Resolves a relative asset path by combining it with a base URL, assets path, and slug.
    ///
    /// This method builds a complete asset URL by handling various cases:
    /// - If the base URL or assets path is empty, it returns the original string.
    /// - If the string starts with `/`, it appends the string directly to the base URL.
    /// - If the string starts with a relative prefix (e.g., `./assetsPath/`), it removes the prefix
    ///   and combines the base URL, assets path, slug, and remaining path parts into a full URL.
    ///
    /// - Parameters:
    ///   - baseUrl: The base URL used to form the full path.
    ///   - assetsPath: The relative directory for the assets.
    ///   - slug: A string inserted in the final path for identification or grouping.
    /// - Returns: A full string URL combining all parts, or the original string if no resolution is applied.
    func resolveAsset(
        baseUrl: String,
        assetsPath: String,
        slug: String
    ) -> String {

        if self == "./images/defaults/default.jpg" {
            print("fooo")
        }
        print(self)
        print("----")
        if baseUrl.isEmpty || assetsPath.isEmpty {
            return self
        }

        let baseUrl = baseUrl.dropTrailingSlash()
        if hasPrefix("/") {
            return [baseUrl, dropLeadingSlash()].joined(separator: "/")
        }

        let prefix = "./\(assetsPath)/"
        guard hasPrefix(prefix) else {
            return self
        }

        let src = String(dropFirst(prefix.count))

        return [baseUrl, assetsPath, slug, src]
            .filter { !$0.isEmpty }
            .joined(separator: "/")
    }
}

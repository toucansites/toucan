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

    /// Replaces the first occurrence of a given character with a specified string.
    ///
    /// This method searches the string for the first occurrence of the provided character.
    /// If found, it replaces that character with the given replacement string.
    ///
    /// - Parameters:
    ///   - target: The character to search for.
    ///   - replacement: The string to replace the first occurrence with.
    /// - Returns: A new string with the first occurrence of the character replaced,
    ///   or the original string if the character is not found or is `nil`.
    func replacingFirstOccurrence(
        of target: Character?,
        with replacement: String
    ) -> String {
        guard let target, let index = firstIndex(of: target)
        else {
            return self
        }

        var modified = self
        modified.replaceSubrange(index...index, with: replacement)
        return modified
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

    /// Resolves a relative asset path into an absolute URL based on the given base URL, asset path, and slug.
    ///
    /// This method replaces a `{{baseUrl}}` token or a relative asset path prefix with a fully constructed path,
    /// combining the base URL, asset path, and slug. Special handling is done for cases where the path starts
    /// with a known offset or a template placeholder.
    ///
    /// - Parameters:
    ///   - baseUrl: The base URL to use for constructing the absolute asset path.
    ///   - assetsPath: The relative path segment to the assets directory.
    ///   - slug: An identifier to insert into the resulting asset path.
    /// - Returns: A new string with resolved asset path based on input values.
    func resolveAsset(
        baseUrl: String,
        assetsPath: String,
        slug: String
    ) -> String {
        if baseUrl.isEmpty || assetsPath.isEmpty {
            return self
        }

        if contains("{{baseUrl}}") {
            let baseUrlPath = baseUrl.ensureTrailingSlash()
            var value = self
            if let slashIndex = firstIndex(of: "/") {
                let offset = distance(
                    from: startIndex,
                    to: slashIndex
                )
                if offset == 11 {
                    value = value.replacingFirstOccurrence(of: "/", with: "")
                }
            }
            return value.replacingOccurrences(
                of: "{{baseUrl}}",
                with: baseUrlPath
            )
        }

        let prefix = "./\(assetsPath)/"
        guard hasPrefix(prefix) else {
            return self
        }

        let src = String(dropFirst(prefix.count))

        return [
            "\(baseUrl.ensureTrailingSlash())\(assetsPath)",
            slug,
            src,
        ]
        .filter { !$0.isEmpty }.joined(separator: "/")
    }
}

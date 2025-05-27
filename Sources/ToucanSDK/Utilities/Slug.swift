//
//  Slug.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 17..
//

/// A value type representing a URL-friendly identifier for a content item.
public struct Slug: Codable, Equatable {

    /// The raw slug string (e.g., `"blog/welcome"`, `"about"`, `""`).
    public var value: String

    /// Initializes a new slug.
    ///
    /// - Parameter value: The raw slug string.
    public init(value: String) {
        self.value = value
    }

    // MARK: - Iterator ID Extraction

    // MARK: - Permalink Generation

    /// Constructs a permalink from the base URL and the slug.
    ///
    /// - Parameter baseUrl: The base URL of the site (e.g., `"https://example.com"`).
    /// - Returns: A fully-qualified permalink string (e.g., `"https://example.com/blog/"`).
    //    public func permalink(baseUrl: String) -> String {
    //        let components = value.split(separator: "/").map(String.init)
    //        if components.isEmpty {
    //            return baseUrl.ensureTrailingSlash()
    //        }
    //        if components.last?.split(separator: ".").count ?? 0 > 1 {
    //            // If last segment has a file extension, return without trailing slash
    //            return ([baseUrl] + components).joined(separator: "/")
    //        }
    //        return ([baseUrl] + components)
    //            .joined(separator: "/")
    //            .ensureTrailingSlash()
    //    }

    // MARK: - Identifier

    /// Extracts the final path component of the slug as a simplified identifier.
    ///
    /// Useful for labeling pages or assigning anchor references.
    ///
    /// - Returns: The last segment of the slug (e.g., `"welcome"` from `"blog/welcome"`).
    //    public func contextAwareIdentifier() -> String {
    //        return String(value.split(separator: "/").last ?? "")
    //    }
}

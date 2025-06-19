//
//  Slug.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 17..
//

/// A value type representing a URL-friendly identifier for a content item.
public struct Slug: Equatable {

    /// The raw slug string (e.g., `"blog/welcome"`, `"about"`, `""`).
    public var value: String

    /// Initializes a new slug.
    ///
    /// - Parameter value: The raw slug string.
    public init(
        _ value: String
    ) {
        self.value = value
    }

    /// Extracts a dynamic iterator identifier from a slug value containing
    /// a templated range (e.g., `"blog/{{page}}"` → `"page"`).
    ///
    /// - Returns: The identifier inside `{{...}}`, or `nil` if not found.
    public func extractIteratorID() -> String? {
        guard
            let startRange = value.range(of: "{{"),
            let endRange = value.range(
                of: "}}",
                range: startRange.upperBound..<value.endIndex
            )
        else {
            return nil
        }
        return .init(value[startRange.upperBound..<endRange.lowerBound])
    }

    /// Constructs a permalink from the base URL and the slug.
    ///
    /// - Parameter baseURL: The base URL of the site (e.g., `"https://example.com"`).
    /// - Returns: A fully-qualified permalink string (e.g., `"https://example.com/blog/"`).
    public func permalink(baseURL: String) -> String {
        let components = value.split(separator: "/").map(String.init)
        if components.isEmpty {
            return baseURL.ensureTrailingSlash()
        }
        if components.last?.split(separator: ".").count ?? 0 > 1 {
            // If last segment has a file extension, return without trailing slash
            return ([baseURL] + components).joined(separator: "/")
        }
        return ([baseURL] + components)
            .joined(separator: "/")
            .ensureTrailingSlash()
    }
}

extension Slug: Codable {
    
    public func contextAwareIdentifier() -> String {
        .init(value.split(separator: "/").last ?? "")
    }
    
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

//
//  ReservedFrontMatter.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 04..
//

import Foundation

/// Represents reserved metadata fields extracted from the front matter of a content file.
public struct ReservedFrontMatter: Decodable, Equatable {

    /// The declared content type (e.g., `"post"`, `"product"`, `"page"`).
    ///
    /// This can override or hint the type during content classification.
    public let type: String?

    // Reserved for future use: definitions of asset-specific metadata.
    // public let assetProperties: [AssetProperty]?

    /// Returns a reserved front matter instance with all fields empty.
    ///
    /// - Returns: An empty `ReservedFrontMatter` object.
    public static func empty() -> Self {
        .init(type: nil)
    }

    /// Initializes a new instance with an optional content type.
    ///
    /// - Parameter type: The reserved type value, or `nil` if not specified.
    public init(type: String?) {
        self.type = type
        // self.assetProperties = nil
    }
}

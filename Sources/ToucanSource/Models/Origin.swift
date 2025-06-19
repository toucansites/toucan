//
//  Origin.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 30..
//

/// Represents the source origin of a content item.
public struct Origin: Equatable {

    /// The original path of the page bundle directory.
    ///
    /// This also acts as a unique identifier for the content within the file system.
    public var path: Path

    /// The slug, typically derived from the path and influenced by noindex files or directory structure.
    ///
    /// This slug is used to generate URLs, permalinks, or unique identifiers in the rendered site.
    public var slug: String

    // MARK: - Lifecycle

    /// Initializes a new `Origin` instance with the given path and slug.
    ///
    /// - Parameters:
    ///   - path: The source directory of the content.
    ///   - slug: The derived slug based on the path and metadata.
    public init(
        path: Path,
        slug: String
    ) {
        self.path = path
        self.slug = slug
    }
}

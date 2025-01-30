//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 30..
//

public struct Origin {
    // var id: String => local identifier within a type for relations
    // var type: String => content type
    /// The original path of the page bundle directory, also serves as the content identifier.
    public var path: String
    /// The slug, derermined by the path and noindex files.
    public var slug: String

    public init(
        path: String,
        slug: String
    ) {
        self.path = path
        self.slug = slug
    }
}

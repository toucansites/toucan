//
//  Origin.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 30..
//

public struct Origin: Equatable, Comparable {

    public static func < (lhs: Origin, rhs: Origin) -> Bool {
        lhs.slug < rhs.slug
    }

    /// The original path of the page bundle directory, also serves as the content identifier.
    public var path: String
    /// The slug, derermined by the path and noindex files.
    public var slug: String

    public init(path: String, slug: String) {
        self.path = path
        self.slug = slug
    }
}

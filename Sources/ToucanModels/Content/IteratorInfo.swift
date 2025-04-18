//
//  IteratorInfo.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 17..
//

/// Provides pagination and iteration metadata for a content collection,
/// used when rendering paginated list views.
public struct IteratorInfo {

    /// Represents a navigation link within a paginated content sequence.
    public struct Link: Codable {

        /// The page number this link points to.
        public var number: Int

        /// The permalink URL for this page.
        public var permalink: String

        /// Whether this link refers to the currently active page.
        public var isCurrent: Bool

        /// Initializes a new pagination link.
        ///
        /// - Parameters:
        ///   - number: The page number.
        ///   - permalink: The URL for that page.
        ///   - isCurrent: Whether this link is for the current page.
        public init(
            number: Int,
            permalink: String,
            isCurrent: Bool
        ) {
            self.number = number
            self.permalink = permalink
            self.isCurrent = isCurrent
        }
    }

    // MARK: - Pagination Info

    /// The current page number (1-based).
    public var current: Int

    /// The total number of pages in the iterator.
    public var total: Int

    /// The number of items per page.
    public var limit: Int

    // MARK: - Content & Navigation

    /// The subset of `Content` items that belong to the current page.
    public var items: [Content]

    /// A list of links to all available pages for UI navigation.
    public var links: [Link]

    // MARK: - Scope

    /// An optional scope key used to identify the context or view this iterator belongs to.
    ///
    /// This can help differentiate between multiple iterators for the same content type
    /// (e.g., "allPosts", "featuredPosts").
    public var scope: String?

    // MARK: - Initialization

    /// Initializes a new iterator metadata structure.
    ///
    /// - Parameters:
    ///   - current: The current page number.
    ///   - total: The total number of pages.
    ///   - limit: Items per page.
    ///   - items: The content items for the current page.
    ///   - links: Pagination links to all pages.
    ///   - scope: An optional scope identifier.
    public init(
        current: Int,
        total: Int,
        limit: Int,
        items: [Content],
        links: [Link],
        scope: String?
    ) {
        self.current = current
        self.total = total
        self.limit = limit
        self.items = items
        self.links = links
        self.scope = scope
    }
}

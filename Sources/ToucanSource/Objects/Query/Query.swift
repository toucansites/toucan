//
//  Query.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 15..
//

/// Represents a content query used to fetch or filter content entries
/// based on content type, pagination, sorting, and filtering criteria.
public struct Query: Codable, Equatable {
    // MARK: - Coding Keys

    /// Keys used to decode the query from a structured format like YAML or JSON.
    enum CodingKeys: String, CodingKey {
        case contentType
        case scope
        case limit
        case offset
        case filter
        case orderBy
    }

    /// The content type this query targets (e.g., `"blog"`, `"author"`, `"product"`).
    public var contentType: String

    /// An optional named scope to apply custom context (e.g., `"homepage"`, `"featured"`).
    public var scope: String?

    /// Optional limit for how many items to return.
    public var limit: Int?

    /// Optional offset for pagination, defining how many items to skip.
    public var offset: Int?

    /// An optional filter condition to narrow results (e.g., field comparison, boolean logic).
    public var filter: Condition?

    /// A list of fields and directions for ordering results.
    public var orderBy: [Order]

    // MARK: - Initialization

    /// Initializes a `Query` with specified properties.
    ///
    /// - Parameters:
    ///   - contentType: The name of the content type being queried.
    ///   - scope: An optional named context or scope for this query.
    ///   - limit: The number of results to limit to.
    ///   - offset: The number of results to skip (for pagination).
    ///   - filter: A filter condition to apply to the results.
    ///   - orderBy: Sorting rules for the query results.
    public init(
        contentType: String,
        scope: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        filter: Condition? = nil,
        orderBy: [Order] = []
    ) {
        self.contentType = contentType
        self.scope = scope
        self.limit = limit
        self.offset = offset
        self.filter = filter
        self.orderBy = orderBy
    }

    // MARK: - Decoding

    /// Decodes a `Query` instance from a decoder, applying defaults for optional values.
    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let contentType = try container.decode(
            String.self,
            forKey: .contentType
        )
        let scope = try container.decodeIfPresent(String.self, forKey: .scope)
        let limit = try container.decodeIfPresent(Int.self, forKey: .limit)
        let offset = try container.decodeIfPresent(Int.self, forKey: .offset)
        let filter = try container.decodeIfPresent(
            Condition.self,
            forKey: .filter
        )
        let orderBy =
            try container.decodeIfPresent([Order].self, forKey: .orderBy) ?? []

        self.init(
            contentType: contentType,
            scope: scope,
            limit: limit,
            offset: offset,
            filter: filter,
            orderBy: orderBy
        )
    }
}

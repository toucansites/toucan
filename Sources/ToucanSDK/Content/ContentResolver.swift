//
//  ContentResolver.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import Foundation
import ToucanCore
import ToucanSource
import ToucanSerialization
import Logging

fileprivate extension String {

    // TODO: this is duplicate -> raw content id?
    func trimmingBracketsContent() -> String {
        var result = ""
        var insideBrackets = false

        let decoded = self.removingPercentEncoding ?? self

        for char in decoded {
            if char == "[" {
                insideBrackets = true
            }
            else if char == "]" {
                insideBrackets = false
            }
            else if !insideBrackets {
                result.append(char)
            }
        }
        return result
    }
}

enum ContentResolverError: ToucanError {

    case contentType(ContentTypeResolverError)
    case unknown(Error)

    var underlyingErrors: [any Error] {
        switch self {
        case .contentType(let error):
            return [error]
        case .unknown(let error):
            return [error]
        }
    }

    var logMessage: String {
        switch self {
        case .contentType(let error):
            return "Content type related error: \(error.logMessage)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    var userFriendlyMessage: String {
        switch self {
        case .contentType(let error):
            return "Content type related error: \(error.userFriendlyMessage)"
        case .unknown:
            return "Unknown content conversion error."
        }
    }
}

struct ContentResolver {

    var contentTypeResolver: ContentTypeResolver
    var encoder: ToucanEncoder
    var decoder: ToucanDecoder
    var dateFormatter: ToucanDateFormatter
    var logger: Logger

    init(
        contentTypeResolver: ContentTypeResolver,
        encoder: ToucanEncoder,
        decoder: ToucanDecoder,
        dateFormatter: ToucanDateFormatter,
        logger: Logger = .subsystem("content-resolver")
    ) {
        self.contentTypeResolver = contentTypeResolver
        self.encoder = encoder
        self.decoder = decoder
        self.dateFormatter = dateFormatter
        self.logger = logger
    }

    func resolve(
        rawContents: [RawContent],
        filterRules: [String: Condition],
        iterators: [String: Query],
        now: TimeInterval
    ) throws(ContentResolverError) -> [Content] {

        let contents = try convert(
            rawContents: rawContents
        )

        let filteredContents = apply(
            filterRules: filterRules,
            to: contents,
            now: now
        )

        let finalContents = apply(
            iterators: iterators,
            to: filteredContents,
            now: now
        )

        return finalContents
    }

    // MARK: - conversion

    func convert(
        rawContents: [RawContent]
    ) throws(ContentResolverError) -> [Content] {
        do {
            return try rawContents.map {
                try convert(rawContent: $0)
            }
        }
        catch let error as ContentResolverError {
            throw error
        }
        catch {
            throw .unknown(error)
        }
    }

    // MARK: - error helper

    func getContentType(
        for origin: Origin,
        using id: String?
    ) throws(ContentResolverError) -> ContentDefinition {
        do {
            return try contentTypeResolver.getContentType(
                for: origin,
                using: id
            )
        }
        catch {
            throw .contentType(error)
        }
    }

    // MARK: - conversion helpers

    // TODO: throw instead of warning...
    func convert(
        property: Property,
        rawValue: AnyCodable?,
        forKey key: String
    ) -> AnyCodable? {
        let value = rawValue ?? property.default

        switch property.type {
        case .date(let config):
            guard
                let rawDateValue = value?.value(as: String.self)
            else {
                logger.warning(
                    "Date property is not a string (\(key): \(value?.value ?? "nil"))."
                )
                return nil
            }
            guard
                let date = dateFormatter.date(
                    from: rawDateValue,
                    using: config
                )
            else {
                logger.warning(
                    "Date property is not valid (\(key): \(rawDateValue))."
                )
                return nil
            }
            return .init(date.timeIntervalSince1970)
        default:
            return value
        }
    }

    func convert(
        rawContent: RawContent
    ) throws(ContentResolverError) -> Content {

        //        logger.debug("Converting raw content")

        let typeId = rawContent.markdown.frontMatter.string("type")

        let contentType = try getContentType(
            for: rawContent.origin,
            using: typeId
        )

        var properties: [String: AnyCodable] = [:]

        // Convert schema-defined properties
        for (key, property) in contentType.properties.sorted(by: {
            $0.key < $1.key
        }) {

            let rawValue = rawContent.markdown.frontMatter[key]

            //            logger.debug("Converting property")
            properties[key] = convert(
                property: property,
                rawValue: rawValue,
                forKey: key
            )
        }

        // Convert schema-defined relations
        var relations: [String: RelationValue] = [:]
        for (key, relation) in contentType.relations.sorted(by: {
            $0.key < $1.key
        }) {
            let rawValue = rawContent.markdown.frontMatter[key]
            var identifiers: [String] = []

            switch relation.type {
            case .one:
                if let id = rawValue?.value as? String {
                    identifiers.append(id)
                }
            case .many:
                if let ids = rawValue?.value as? [String] {
                    identifiers.append(contentsOf: ids)
                }
            }

            relations[key] = .init(
                contentType: relation.references,
                type: relation.type,
                identifiers: identifiers
            )
        }

        // Filter out reserved keys and schema-mapped fields to extract user-defined fields
        let keysToRemove =
            ["id", "type", "slug"]
            + contentType.properties.keys
            + contentType.relations.keys

        var userDefined = rawContent.markdown.frontMatter
        for key in keysToRemove {
            userDefined.removeValue(forKey: key)
        }

        // Extract `id` from front matter or fallback from origin path
        var id: String =
            rawContent.origin.path
            .split(separator: "/")
            .dropLast()
            .last
            .map(String.init)?
            .trimmingBracketsContent() ?? ""

        if let rawId = rawContent.markdown.frontMatter.string("id") {
            id = rawId
        }

        // Extract `slug` from front matter or fallback to origin slug
        var slug: String = rawContent.origin.slug
        if let rawSlug = rawContent.markdown.frontMatter.string(
            "slug",
            allowingEmptyValue: true
        ) {
            slug = rawSlug
        }

        // Final assembled content object
        return .init(
            id: id,
            slug: .init(value: slug),
            rawValue: rawContent,
            definition: contentType,
            properties: properties,
            relations: relations,
            userDefined: userDefined,
            iteratorInfo: nil
        )
    }

    // MARK: - filter

    /// Applies the filtering rules to the provided content items.
    ///
    /// - Parameters:
    ///   - filterRules: A dictionary mapping content type identifiers to filtering conditions.
    ///   - contents: The list of `Content` items to filter.
    ///   - now: The current timestamp used for time-based filtering.
    /// - Returns: A new list containing only the filtered content items.
    func apply(
        filterRules: [String: Condition],
        to contents: [Content],
        now: TimeInterval
    ) -> [Content] {
        let groups = Dictionary(grouping: contents, by: { $0.definition.id })

        var result: [Content] = []
        for (id, contents) in groups {
            if let condition = filterRules[id] ?? filterRules["*"] {
                let items = contents.run(
                    query: .init(
                        contentType: id,
                        filter: condition
                    ),
                    now: now
                )
                result.append(contentsOf: items)
            }
            else {
                result.append(contentsOf: contents)
            }
        }
        return result
    }

    // MARK: - iterators

    /// Extracts a dynamic iterator identifier from a slug value containing
    /// a templated range (e.g., `"blog/{{page}}"` → `"page"`).
    ///
    /// - Returns: The identifier inside `{{...}}`, or `nil` if not found.
    private func extractIteratorId(from slug: String) -> String? {
        guard
            let startRange = slug.range(of: "{{"),
            let endRange = slug.range(
                of: "}}",
                range: startRange.upperBound..<slug.endIndex
            )
        else {
            return nil
        }
        return .init(slug[startRange.upperBound..<endRange.lowerBound])
    }

    func apply(
        iterators: [String: Query],
        to contents: [Content],
        now: TimeInterval
    ) -> [Content] {
        var finalContents: [Content] = []

        for content in contents {
            if let iteratorId = extractIteratorId(from: content.slug.value) {
                guard
                    let query = iterators[iteratorId]
                else {
                    continue
                }

                let countQuery = Query(
                    contentType: query.contentType,
                    scope: query.scope,
                    limit: nil,
                    offset: nil,
                    filter: query.filter,
                    orderBy: query.orderBy
                )

                let total = contents.run(query: countQuery, now: now).count
                let limit = max(1, query.limit ?? 10)
                let numberOfPages = (total + limit - 1) / limit

                for i in 0..<numberOfPages {
                    let offset = i * limit
                    let currentPageIndex = i + 1

                    var alteredContent = content
                    rewrite(
                        iteratorId: iteratorId,
                        pageIndex: currentPageIndex,
                        &alteredContent.id
                    )
                    rewrite(
                        iteratorId: iteratorId,
                        pageIndex: currentPageIndex,
                        &alteredContent.slug.value
                    )
                    rewrite(
                        number: currentPageIndex,
                        total: numberOfPages,
                        &alteredContent.properties
                    )
                    rewrite(
                        number: currentPageIndex,
                        total: numberOfPages,
                        &alteredContent.userDefined
                    )

                    if !alteredContent.rawValue.markdown.contents.isEmpty {
                        alteredContent.rawValue.markdown.contents = replace(
                            in: alteredContent.rawValue.markdown.contents,
                            number: currentPageIndex,
                            total: numberOfPages
                        )
                    }

                    //                    let links = (0..<numberOfPages)
                    //                        .map { i in
                    //                            let pageIndex = i + 1
                    //                            let permalink = content.slug.permalink(
                    //                                baseUrl: baseUrl
                    //                            )
                    //                            return IteratorInfo.Link(
                    //                                number: pageIndex,
                    //                                permalink: permalink.replacingOccurrences(
                    //                                    ["{{\(iteratorId)}}": String(pageIndex)]),
                    //                                isCurrent: pageIndex == currentPageIndex
                    //                            )
                    //                        }

                    let items = contents.run(
                        query: .init(
                            contentType: query.contentType,
                            limit: limit,
                            offset: offset,
                            filter: query.filter,
                            orderBy: query.orderBy
                        ),
                        now: now
                    )

                    alteredContent.iteratorInfo = .init(
                        current: currentPageIndex,
                        total: numberOfPages,
                        limit: limit,
                        items: items,
                        links: [],
                        scope: query.scope
                    )

                    finalContents.append(alteredContent)
                }

            }
            else {
                finalContents.append(content)
            }
        }
        return finalContents
    }

    private func rewrite(
        iteratorId: String,
        pageIndex: Int,
        _ value: inout String
    ) {
        value = value.replacingOccurrences([
            "{{\(iteratorId)}}": String(pageIndex)
        ])
    }

    private func rewrite(
        number: Int,
        total: Int,
        _ array: inout [String: AnyCodable]
    ) {
        for (key, _) in array {
            if let stringValue = array[key]?.stringValue() {
                array[key] = .init(
                    replace(
                        in: stringValue,
                        number: number,
                        total: total
                    )
                )
            }
        }
    }

    private func replace(
        in value: String,
        number: Int,
        total: Int
    ) -> String {
        value.replacingOccurrences([
            "{{number}}": String(number),
            "{{total}}": String(total),
        ])
    }
}

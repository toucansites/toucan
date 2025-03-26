//
//  ContextBundleCreator.swift
//
//  Created by gerp83 on 2025. 03. 26.
//

import Foundation
import ToucanModels
import ToucanContent
import FileManagerKit
import Logging
    
public struct ContextBundleCreator {
    
    var sourceBundle: SourceBundle
    let fileManager: FileManagerKit
    let logger: Logger
    let dateFormatter: DateFormatter
    var contextCache: [String: [String: AnyCodable]] = [:]
    var contentSlugsToRemove: [String] = []
    var contentsToAdd: [Content] = []
    
    init(
        sourceBundle: SourceBundle,
        fileManager: FileManagerKit,
        logger: Logger,
        dateFormatter: DateFormatter,
        contextCache: inout [String : [String : AnyCodable]]
    ) {
        self.sourceBundle = sourceBundle
        self.fileManager = fileManager
        self.logger = logger
        self.dateFormatter = dateFormatter
        self.contextCache = contextCache
    }
    
    mutating func getContextBundles(
        siteContext: [String: AnyCodable],
        pipeline: Pipeline
    ) throws -> ([ContextBundle], [String], [Content]) {

        var bundles: [ContextBundle] = []

        for content in sourceBundle.contents {

            let pipelineContext = getPipelineContext(
                for: pipeline,
                currentSlug: content.slug
            )
            .recursivelyMerged(with: siteContext)

            if let iteratorId = extractIteratorId(from: content.slug) {
                guard
                    let query = pipeline.iterators[iteratorId],
                    pipeline.contentTypes.isAllowed(
                        contentType: query.contentType
                    )
                else {
                    continue
                }
                contentSlugsToRemove.append(content.slug)

                let countQuery = Query(
                    contentType: query.contentType,
                    scope: query.scope,
                    limit: nil,
                    offset: nil,
                    filter: query.filter,
                    orderBy: query.orderBy
                )

                let total = sourceBundle.run(query: countQuery).count
                let limit = max(1, query.limit ?? 10)
                let numberOfPages = (total + limit - 1) / limit

                struct PageLink: Codable {
                    let number: Int
                    let permalink: String
                    let isCurrent: Bool
                }

                for i in 0..<numberOfPages {
                    let offset = i * limit
                    let currentPageIndex = i + 1

                    let links = (0..<numberOfPages)
                        .map { i in
                            let pageIndex = i + 1
                            let slug = content.slug.replacingOccurrences([
                                "{{\(iteratorId)}}": String(pageIndex)
                            ])
                            return PageLink(
                                number: pageIndex,
                                permalink: slug.permalink(
                                    baseUrl: sourceBundle.settings.baseUrl
                                ),
                                isCurrent: pageIndex == currentPageIndex
                            )
                        }

                    let pageItems = sourceBundle.run(
                        query: .init(
                            contentType: query.contentType,
                            limit: limit,
                            offset: offset,
                            filter: query.filter,
                            orderBy: query.orderBy
                        )
                    )

                    let id = content.id.replacingOccurrences([
                        "{{\(iteratorId)}}": String(currentPageIndex)
                    ])
                    let slug = content.slug.replacingOccurrences([
                        "{{\(iteratorId)}}": String(currentPageIndex)
                    ])

                    var alteredContent = content
                    alteredContent.id = id
                    alteredContent.slug = slug

                    let number = currentPageIndex
                    let total = numberOfPages

                    replaceMap(number: number, total: total, array: &alteredContent.properties)
                    replaceMap(number: number, total: total, array: &alteredContent.userDefined)

                    var itemCtx: [[String: AnyCodable]] = []
                    for pageItem in pageItems {
                        let pageItemCtx = getContextObject(
                            for: pageItem,
                            pipeline: pipeline,
                            scopeKey: query.scope ?? "list",
                            currentSlug: slug
                        )
                        itemCtx.append(pageItemCtx)
                    }

                    let iteratorContext: [String: AnyCodable] = [
                        "iterator": .init(
                            [
                                "total": .init(total),
                                "limit": .init(limit),
                                "current": .init(currentPageIndex),
                                "items": .init(itemCtx),
                                "links": .init(links),
                            ] as [String: AnyCodable]
                        )
                    ]
                    .recursivelyMerged(with: pipelineContext)

                    let bundle = getContextBundle(
                        content: alteredContent,
                        using: pipeline,
                        extraContext: iteratorContext
                    )
                    bundles.append(bundle)
                    
                    var newContent = content
                    let newSlug = newContent.slug.replacingOccurrences(of: "{{\(iteratorId)}}", with: "\(currentPageIndex)")
                    newContent.slug = newSlug
                    contentsToAdd.append(newContent)
                }
                
                continue
            }

            let isAllowed = pipeline.contentTypes.isAllowed(
                contentType: content.definition.id
            )

            guard isAllowed else {
                continue
            }

            let bundle = getContextBundle(
                content: content,
                using: pipeline,
                extraContext: pipelineContext
            )
            bundles.append(bundle)
        }
        return (bundles, contentSlugsToRemove, contentsToAdd)
    }
    
    private func replaceMap(
        number: Int,
        total: Int,
        array: inout [String: AnyCodable]
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
    
    private mutating func getPipelineContext(
        for pipeline: Pipeline,
        currentSlug: String
    ) -> [String: AnyCodable] {
        var rawContext: [String: AnyCodable] = [:]
        for (key, query) in pipeline.queries {
            let results = sourceBundle.run(query: query)

            rawContext[key] = .init(
                results.map {
                    getContextObject(
                        for: $0,
                        pipeline: pipeline,
                        scopeKey: query.scope ?? "list",
                        currentSlug: currentSlug
                    )
                }
            )
        }
        return ["context": .init(rawContext)]
    }
    
    // MARK: - helper for pagination stuff

    private mutating func getContextBundle(
        content: Content,
        using pipeline: Pipeline,
        extraContext: [String: AnyCodable]
    ) -> ContextBundle {

        let ctx = getContextObject(
            for: content,
            pipeline: pipeline,
            scopeKey: "detail",
            currentSlug: content.slug
        )
        let context: [String: AnyCodable] = [
            //            content.definition.type: .init(ctx),
            "page": .init(ctx)
        ]
        .recursivelyMerged(with: extraContext)

        // TODO: more path arguments?
        let outputArgs: [String: String] = [
            "{{id}}": content.id,
            "{{slug}}": content.slug,
        ]

        let path = pipeline.output.path.replacingOccurrences(outputArgs)
        let file = pipeline.output.file.replacingOccurrences(outputArgs)
        let ext = pipeline.output.ext.replacingOccurrences(outputArgs)

        return .init(
            content: content,
            context: context,
            destination: .init(
                path: path,
                file: file,
                ext: ext
            )
        )
    }
    
    private func extractIteratorId(
        from input: String
    ) -> String? {
        guard
            let startRange = input.range(of: "{{"),
            let endRange = input.range(
                of: "}}",
                range: startRange.upperBound..<input.endIndex
            )
        else {
            return nil
        }
        return .init(input[startRange.upperBound..<endRange.lowerBound])
    }
    
    private mutating func getContextObject(
        for content: Content,
        pipeline: Pipeline,
        scopeKey: String,
        currentSlug: String?,
        allowSubQueries: Bool = true  // allow top level queries only
    ) -> [String: AnyCodable] {
        var result: [String: AnyCodable] = [:]

        let scope = pipeline.getScope(
            keyedBy: scopeKey,
            for: content.definition.id
        )

        let cacheKey = [
            pipeline.id,
            content.slug,
            //            currentSlug ?? "",  // still a bit slow due to this
            scopeKey,
            String(allowSubQueries),
        ]
        .joined(separator: "_")

        if let cachedContext = contextCache[cacheKey] {
            return cachedContext
        }

        if scope.context.contains(.userDefined) {
            result = result.recursivelyMerged(with: content.userDefined)
        }

        if scope.context.contains(.properties) {
            for (k, v) in content.properties {
                if let p = content.definition.properties[k],
                    case .date(_) = p.type,
                    let rawDate = v.value(as: Double.self)
                {
                    result[k] = .init(
                        rawDate.convertToDateFormats(
                            formatter: dateFormatter,
                            formats: sourceBundle.config.dateFormats.output
                        )
                    )
                }
                else {
                    result[k] = .init(v.value)
                }
            }

            // TODO: web only properties
            result["slug"] = .init(content.slug)
            result["permalink"] = .init(
                content.slug.permalink(baseUrl: sourceBundle.settings.baseUrl)
            )

            //            result["isCurrentURL"] = .init(content.slug == currentSlug)
            result["lastUpdate"] = .init(
                content.rawValue.lastModificationDate.convertToDateFormats(
                    formatter: dateFormatter,
                    formats: sourceBundle.config.dateFormats.output
                )
            )
        }

        if scope.context.contains(.contents) {
            let renderer = ContentRenderer(
                configuration: .init(
                    markdown: .init(
                        customBlockDirectives: sourceBundle.blockDirectives
                    ),
                    outline: .init(levels: [2, 3]),
                    readingTime: .init(
                        wordsPerMinute: 238
                    ),
                    transformerPipeline: pipeline.transformers[
                        content.definition.id
                    ]
                ),
                fileManager: fileManager,
                logger: logger
            )

            let contents = renderer.render(
                content: content.rawValue.markdown,
                slug: content.slug,
                assetsPath: sourceBundle.config.contents.assets.path,
                baseUrl: sourceBundle.baseUrl
            )

            result["contents"] = [
                "html": contents.html,
                "readingTime": contents.readingTime,
                "outline": contents.outline,
            ]
        }

        if scope.context.contains(.relations) {
            for (key, relation) in content.definition.relations {
                var orderBy: [Order] = []
                if let order = relation.order {
                    orderBy.append(order)
                }

                let relationContents = sourceBundle.run(
                    query: .init(
                        contentType: relation.references,
                        filter: .field(
                            key: "id",
                            operator: .in,
                            value: .init(
                                content.relations[key]?.identifiers ?? []
                            )
                        ),
                        orderBy: orderBy
                    )
                )
                result[key] = .init(
                    relationContents.map {
                        getContextObject(
                            for: $0,
                            pipeline: pipeline,
                            scopeKey: "reference",
                            currentSlug: currentSlug,
                            allowSubQueries: false
                        )
                    }
                )
            }
        }

        if allowSubQueries, scope.context.contains(.queries) {

            for (key, query) in content.definition.queries {
                let queryContents = sourceBundle.run(
                    query: query.resolveFilterParameters(
                        with: content.queryFields
                    )
                )

                result[key] = .init(
                    queryContents.map {
                        getContextObject(
                            for: $0,
                            pipeline: pipeline,
                            scopeKey: query.scope ?? "list",
                            currentSlug: currentSlug,
                            allowSubQueries: false
                        )
                    }
                )
            }
        }

        guard !scope.fields.isEmpty else {
            contextCache[cacheKey] = result
            return result
        }
        contextCache[cacheKey] = result
        return result.filter { scope.fields.contains($0.key) }
    }
    
}

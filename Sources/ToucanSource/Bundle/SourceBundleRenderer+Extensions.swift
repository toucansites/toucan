//
//  Extensions.swift
//
//  Created by gerp83 on 2025. 03. 26.
//

import Foundation
import ToucanModels
import ToucanContent

extension SourceBundleRenderer {

    mutating func getPipelineContext(
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
                        currentSlug: currentSlug,
                        from: "getPipelineContext"
                    )
                }
            )
        }
        return ["context": .init(rawContext)]
    }

    mutating func getContextBundle(
        content: Content,
        using pipeline: Pipeline,
        pipelineContext: [String: AnyCodable]
    ) -> ContextBundle {

        var contextToAdd = pipelineContext

        if !content.iteratorContext.isEmpty {

            let pageItems =
                content.iteratorContext["pageItems"]?.value(as: [Content].self)
                ?? []
            let scopeKey = content.iteratorContext["scopeKey"]?.stringValue()
            let total = content.iteratorContext["total"]?.intValue()
            let limit = content.iteratorContext["limit"]?.intValue()
            let current = content.iteratorContext["current"]?.intValue()

            var itemCtx: [[String: AnyCodable]] = []
            for pageItem in pageItems {
                let pageItemCtx = getContextObject(
                    for: pageItem,
                    pipeline: pipeline,
                    scopeKey: scopeKey ?? "list",
                    currentSlug: content.slug,
                    from: "getContextBundle"
                )
                itemCtx.append(pageItemCtx)
            }

            let iteratorContext: [String: AnyCodable] = [
                "iterator": .init(
                    [
                        "total": .init(total),
                        "limit": .init(limit),
                        "current": .init(current),
                        "items": .init(itemCtx),
                        "links": content.iteratorContext["links"]!,
                    ] as [String: AnyCodable]
                )
            ]
            .recursivelyMerged(with: contextToAdd)

            contextToAdd = iteratorContext
        }

        let ctx = getContextObject(
            for: content,
            pipeline: pipeline,
            scopeKey: "detail",
            currentSlug: content.slug,
            from: "getContextBundle2"
        )
        let context: [String: AnyCodable] = [
            //            content.definition.type: .init(ctx),
            "page": .init(ctx)
        ]
        .recursivelyMerged(with: contextToAdd)

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

    mutating func getContextObject(
        for content: Content,
        pipeline: Pipeline,
        scopeKey: String,
        currentSlug: String?,
        allowSubQueries: Bool = true,  // allow top level queries only,
        from: String
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
                            allowSubQueries: false,
                            from: "getContextObject"
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
                            allowSubQueries: false,
                            from: "getContextObject2"
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

extension Double {

    func convertToDateFormats(
        formatter: DateFormatter,
        formats: [String: String]
    ) -> DateFormats {
        getDates(
            for: self,
            using: formatter,
            formats: formats
        )
    }

    private func getDates(
        for timeInterval: Double,
        using formatter: DateFormatter,
        formats: [String: String] = [:]
    ) -> DateFormats {
        let date = Date(timeIntervalSince1970: timeInterval)

        let styles: [(String, DateFormatter.Style)] = [
            ("full", .full),
            ("long", .long),
            ("medium", .medium),
            ("short", .short),
        ]

        var dateFormats: [String: String] = [:]
        var timeFormats: [String: String] = [:]

        for (key, style) in styles {
            formatter.dateStyle = style
            formatter.timeStyle = .none
            dateFormats[key] = formatter.string(from: date)

            formatter.dateStyle = .none
            formatter.timeStyle = style
            timeFormats[key] = formatter.string(from: date)
        }

        let standard: [String: String] = [
            "iso8601": "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "rss": "EEE, dd MMM yyyy HH:mm:ss Z",
            "sitemap": "yyyy-MM-dd",
        ]
        var custom: [String: String] = [:]
        for (k, f) in formats.recursivelyMerged(with: standard) {
            formatter.dateFormat = f
            custom[k] = formatter.string(from: date)
        }

        return .init(
            date: .init(
                full: dateFormats["full"]!,
                long: dateFormats["long"]!,
                medium: dateFormats["medium"]!,
                short: dateFormats["short"]!
            ),
            time: .init(
                full: timeFormats["full"]!,
                long: timeFormats["long"]!,
                medium: timeFormats["medium"]!,
                short: timeFormats["short"]!
            ),
            timestamp: timeInterval,
            formats: custom
        )
    }

}

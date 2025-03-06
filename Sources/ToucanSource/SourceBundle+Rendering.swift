//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 11..
//

import Foundation
import FileManagerKit
import ToucanModels
import ToucanContent

extension SourceBundle {

    // MARK: - date stuff

    func convertToDateFormats(
        date: Double
    ) -> DateFormats {
        getDates(
            for: date,
            using: dateFormatter,
            formats: config.dateFormats.output
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

    // MARK: - helpers

    func getContextObject(
        for content: Content,
        pipeline: Pipeline,
        scopeKey: String,
        currentSlug: String?,
        allowSubQueries: Bool = true  // allow top level queries only
    ) -> [String: AnyCodable] {
        var result: [String: AnyCodable] = [:]

        let scope = pipeline.getScope(
            keyedBy: scopeKey,
            for: content.definition.type
        )

        if scope.context.contains(.userDefined) {
            result = result.recursivelyMerged(with: content.userDefined)
        }

        if scope.context.contains(.properties) {
            for (k, v) in content.properties {
                if let p = content.definition.properties[k],
                    case .date(_) = p.type,
                    let rawDate = v.value(as: Double.self)
                {
                    result[k] = .init(convertToDateFormats(date: rawDate))
                }
                else {
                    result[k] = .init(v.value)
                }
            }

            // TODO: web only properties
            result["slug"] = .init(content.slug)
            result["permalink"] = .init(
                content.slug.permalink(baseUrl: settings.baseUrl)
            )

            result["isCurrentURL"] = .init(content.slug == currentSlug)
            result["lastUpdate"] = .init(
                convertToDateFormats(
                    date: content.rawValue.lastModificationDate
                )
            )
        }

        if scope.context.contains(.contents) {
            let renderer = ContentRenderer(
                configuration: .init(
                    markdown: .init(
                        customBlockDirectives: blockDirectives
                    ),
                    outline: .init(levels: [2, 3]),
                    readingTime: .init(
                        wordsPerMinute: 238
                    )
                ),
                logger: .init(label: "ContentRenderer")
            )

            let contents = renderer.render(content.rawValue.markdown)

            result["contents"] = [
                "html": contents.html,
                "readingTime": contents.readingTime,
                "outline": contents.outline,
            ]
        }

        if allowSubQueries, scope.context.contains(.relations) {
            for (key, relation) in content.definition.relations {
                var orderBy: [Order] = []
                if let order = relation.order {
                    orderBy.append(order)
                }

                let relationContents = run(
                    query: .init(
                        contentType: relation.references,
                        filter: .field(
                            key: "slug",  // TODO: fix id bug and use id
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
                let queryContents = run(
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
            return result
        }
        return result.filter { scope.fields.contains($0.key) }
    }

    func extractIteratorId(
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

    // MARK: - helper for pagination stuff

    func getContextBundle(
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

    func getContextBundles(
        siteContext: [String: AnyCodable],
        pipeline: Pipeline
    ) throws -> [ContextBundle] {

        var bundles: [ContextBundle] = []

        for content in contents {

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

                let countQuery = Query(
                    contentType: query.contentType,
                    scope: query.scope,
                    limit: nil,
                    offset: nil,
                    filter: query.filter,
                    orderBy: query.orderBy
                )

                let total = run(query: countQuery).count
                let limit = max(1, query.limit ?? 10)
                let numberOfPages = (total + limit - 1) / limit

                for i in 0..<numberOfPages {
                    let offset = i * limit
                    let currentPageIndex = i + 1

                    let pageItems = run(
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

                    // TODO: meh... option to replace {{total}} {{limit}} {{current}}?
                    var alteredContent = content
                    alteredContent.id = id
                    alteredContent.slug = slug

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
                        // TODO: links to other pages?
                        "iterator": .init(
                            [
                                "total": .init(total),
                                "limit": .init(limit),
                                "current": .init(currentPageIndex),
                                query.contentType: [
                                    "items": itemCtx
                                ],
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
                }

                continue
            }

            let isAllowed = pipeline.contentTypes.isAllowed(
                contentType: content.definition.type
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

        return bundles
    }

    func getPipelineContext(
        for pipeline: Pipeline,
        currentSlug: String
    ) -> [String: AnyCodable] {
        var rawContext: [String: AnyCodable] = [:]
        for (key, query) in pipeline.queries {
            let results = run(query: query)

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
        return rawContext
    }

    public func generatePipelineResults() throws -> [PipelineResult] {

        let now = Date().timeIntervalSince1970
        var results: [PipelineResult] = []

        var siteContext: [String: AnyCodable] = [
            "baseUrl": .init(settings.baseUrl),
            "name": .init(settings.name),
            "locale": .init(settings.locale),
            "timeZone": .init(settings.timeZone),
            "lastBuildDate": .init(convertToDateFormats(date: now)),
        ]
        .recursivelyMerged(with: settings.userDefined)

        for pipeline in pipelines {

            var updateTypes = contents.map(\.definition.type)
            if !pipeline.contentTypes.lastUpdate.isEmpty {
                updateTypes = updateTypes.filter {
                    pipeline.contentTypes.lastUpdate.contains($0)
                }
            }

            /// get last update date or use now as last update date.
            let lastUpdate: Double =
                updateTypes.compactMap {
                    let items = self.run(
                        query: .init(
                            contentType: $0,
                            scope: nil,
                            limit: 1,
                            orderBy: [
                                .init(
                                    key: "lastUpdate",
                                    direction: .desc
                                )
                            ]
                        )
                    )
                    return items.first?.rawValue.lastModificationDate
                }
                .sorted(by: >).first ?? now

            let lastUpdateContext = convertToDateFormats(date: lastUpdate)
            siteContext["lastUpdate"] = .init(lastUpdateContext)

            let bundles = try getContextBundles(
                siteContext: [
                    "site": .init(siteContext)
                ],
                pipeline: pipeline
            )

            switch pipeline.engine.id {
            case "json", "context":
                let encoder = JSONEncoder()
                encoder.outputFormatting = [
                    .prettyPrinted,
                    .withoutEscapingSlashes,
                    //.sortedKeys,
                ]

                for bundle in bundles {
                    // TODO: override output using front matter in both cases
                    let data = try encoder.encode(bundle.context)
                    let json = String(data: data, encoding: .utf8)
                    guard let json else {
                        // TODO: log
                        continue
                    }
                    let result = PipelineResult(
                        contents: json,
                        destination: bundle.destination
                    )
                    results.append(result)
                }
            case "mustache":
                let renderer = MustacheTemplateRenderer(
                    templates: try templates.mapValues {
                        try .init(string: $0)
                    }
                )

                for bundle in bundles {
                    let engineOptions = pipeline.engine.options
                    let contentTypesOptions = engineOptions.dict("contentTypes")
                    let bundleOptions = contentTypesOptions.dict(
                        bundle.content.definition.type
                    )

                    let contentTypeTemplate = bundleOptions.string("template")
                    let contentTemplate = bundle.content.rawValue.frontMatter
                        .string("template")
                    let template =
                        contentTemplate ?? contentTypeTemplate
                        ?? "pages.default"  // TODO

                    let html = try renderer.render(
                        template: template,
                        with: bundle.context
                    )

                    guard let html else {
                        // TODO: log
                        continue
                    }
                    let result = PipelineResult(
                        contents: html,
                        destination: bundle.destination
                    )
                    results.append(result)
                }

            default:
                print("ERROR - no such renderer \(pipeline.engine.id)")
            }
        }
        return results
    }

}

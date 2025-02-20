//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 11..
//

import Foundation
import FileManagerKit
import ToucanModels
import ToucanCodable
import ToucanMarkdown
import ToucanToC

public struct Destination {
    public var path: String
    public var file: String
    public var ext: String

    public init(
        path: String,
        file: String,
        ext: String
    ) {
        self.path = path
        self.file = file
        self.ext = ext
    }
}

struct ContextBundle {
    var content: Content
    var context: [String: AnyCodable]
    var destination: Destination
}

// TODO: do we need anything else + information when testing? 🤔
public struct PipelineResult {
    public var contents: String
    public var destination: Destination

    public init(
        contents: String,
        destination: Destination
    ) {
        self.contents = contents
        self.destination = destination
    }
}

extension SourceBundle {

    // MARK: - date stuff

    func convertToDateFormats(
        date: Double
    ) -> DateFormats {
        getDates(
            for: date,
            using: dateFormatter,
            formats: config.dateFormats.output
                .recursivelyMerged(with: [
                    "test": "Y"
                ])
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
        slug: String?,
        for content: Content,
        context: RenderPipeline.Scope.Context,
        using source: SourceBundle,
        allowSubQueries: Bool = true  // allow top level queries only
    ) -> [String: AnyCodable] {

        var result: [String: AnyCodable] = [:]
        if context.contains(.properties) {
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
                content.slug.permalink(baseUrl: source.settings.baseUrl)
            )
            result["isCurrentURL"] = .init(content.slug == slug)
        }

        if allowSubQueries, context.contains(.relations) {
            for (key, relation) in content.definition.relations {
                var orderBy: [Order] = []
                if let order = relation.order {
                    orderBy.append(order)
                }
                let relationContents = source.run(
                    query: .init(
                        contentType: relation.references,
                        scope: "properties",
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
                            slug: content.slug,
                            for: $0,
                            context: .properties,
                            using: self,
                            allowSubQueries: false
                        )
                    }
                )
            }

        }
        if context.contains(.contents) {
            let renderer = MarkdownRenderer(
                customBlockDirectives: [],
                logger: .init(label: "MarkdownRenderer")
            )
            let html = renderer.renderHTML(
                markdown: content.rawValue.markdown
            )
            let outlineParser = OutlineParser(
                levels: [2, 3],
                logger: .init(label: "OutlineParser")
            )
            let outline = outlineParser.parseHTML(html)

            result["contents"] = [
                "html": html,
                "outline": outline,
                "readingTime": html.readingTime(),
            ]
        }
        if allowSubQueries, context.contains(.queries) {
            for (key, query) in content.definition.queries {
                // TODO: replace {{}} variables in query filter values...
                let queryContents = source.run(
                    query: query.resolveFilterParameters(
                        with: content.queryFields
                    )
                )

                result[key] = .init(
                    queryContents.map {
                        getContextObject(
                            slug: content.slug,
                            for: $0,
                            context: .all,
                            using: self,
                            allowSubQueries: false
                        )
                    }
                )
            }
        }
        return result
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
        using pipeline: RenderPipeline,
        extraContext: [String: AnyCodable]
    ) -> ContextBundle {

        let context: [String: AnyCodable] = [
            //                        "global": pipelineContext,
            content.definition.type: .init(
                getContextObject(
                    slug: content.slug,
                    for: content,
                    context: .all,
                    using: self
                )
            )
        ]
        .recursivelyMerged(with: extraContext)

        // TODO: more path arguments
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

    // TODO: return full context instead of complete render?
    func getContextBundles(
        siteContext: [String: AnyCodable],
        pipeline: RenderPipeline
    ) throws -> [ContextBundle] {

        var bundles: [ContextBundle] = []

        for contentBundle in contentBundles {

            for content in contentBundle.contents {

                let pipelineContext = getPipelineContext(
                    for: pipeline,
                    slug: content.slug
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

                        let pageQuery = Query(
                            contentType: query.contentType,
                            scope: query.scope,
                            limit: limit,
                            offset: offset,
                            filter: query.filter,
                            orderBy: query.orderBy
                        )
                        let pageItems = run(query: pageQuery)

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
                                slug: slug,
                                for: pageItem,
                                context: .all,
                                using: self
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

                guard
                    pipeline.contentTypes.isAllowed(
                        contentType: contentBundle.definition.type
                    )
                else {
                    continue
                }

                let bundle = getContextBundle(
                    content: content,
                    using: pipeline,
                    extraContext: pipelineContext
                )
                bundles.append(bundle)
            }
        }
        return bundles
    }

    func getPipelineContext(
        for pipeline: RenderPipeline,
        slug: String
    ) -> [String: AnyCodable] {
        var rawContext: [String: AnyCodable] = [:]
        for (key, query) in pipeline.queries {
            let results = run(query: query)

            let scope = pipeline.getScope(
                keyedBy: query.scope ?? "list",  // TODO: list by default?
                for: query.contentType
            )

            rawContext[key] = .init(
                results.map {
                    getContextObject(
                        slug: nil,
                        for: $0,
                        context: scope.context,
                        using: self
                    )
                }
            )
        }
        return rawContext
    }

    func generatePipelineResults(
        templates: [String: String]
    ) throws -> [PipelineResult] {

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

        for pipeline in renderPipelines {

            var updateTypes = contentBundles.map(\.definition.type)
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

            // TODO: put this under site context?
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
                    guard
                        let json = String(
                            data: data,
                            encoding: .utf8
                        )
                    else {
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
                        .string(
                            "template"
                        )
                    let template =
                        contentTypeTemplate ?? contentTemplate ?? "default"  // TODO

                    guard
                        let html = try renderer.render(
                            template: template,
                            with: bundle.context
                        )
                    else {
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

//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 25..
//

import Foundation
import ToucanModels
import ToucanContent
import FileManagerKit
import Logging

public struct SourceBundleRenderer {

    let sourceBundle: SourceBundle
    let generatorInfo: GeneratorInfo
    let formatters: [String: DateFormatter]
    let fileManager: FileManagerKit
    let logger: Logger

    var contentContextCache: [String: [String: AnyCodable]] = [:]

    public init(
        sourceBundle: SourceBundle,
        generatorInfo: GeneratorInfo = .current,
        fileManager: FileManagerKit,
        logger: Logger
    ) {
        self.sourceBundle = sourceBundle
        self.generatorInfo = generatorInfo
        self.fileManager = fileManager
        self.logger = logger
        self.formatters = Self.prepareFormatters(sourceBundle)
    }

    // MARK: -

    /// Returns the site context based on the source bundle settings and the generator info
    private func getSiteContext(
        for now: TimeInterval
    ) -> [String: AnyCodable] {
        [
            "baseUrl": .init(sourceBundle.settings.baseUrl),
            "name": .init(sourceBundle.settings.name),
            "locale": .init(sourceBundle.settings.locale),
            "timeZone": .init(sourceBundle.settings.timeZone),
            "generation": .init(now.toDateFormats(formatters: formatters)),
            "generator": .init(generatorInfo),
        ]
        // TODO: check if overwritten with e.g.: generator
        .recursivelyMerged(with: sourceBundle.settings.userDefined)
    }

    /// Returns the last content update based on the pipeline config
    private func getLastContentUpdate(
        contents: [Content],
        pipeline: Pipeline
    ) -> TimeInterval? {
        var updateTypes = contents.map(\.definition.id)
        if !pipeline.contentTypes.lastUpdate.isEmpty {
            updateTypes = updateTypes.filter {
                pipeline.contentTypes.lastUpdate.contains($0)
            }
        }
        return
            updateTypes.compactMap {
                let items = contents.run(
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
            .sorted(by: >).first
    }

    // MARK: -
    public mutating func render(
        now: Date
    ) throws -> [PipelineResult] {
        let now = now.timeIntervalSince1970
        var siteContext = getSiteContext(for: now)
        var results: [PipelineResult] = []
        let iteratorResolver = ContentIteratorResolver(
            baseUrl: sourceBundle.settings.baseUrl
        )

        for pipeline in sourceBundle.pipelines {

            let pipelineFormatters = pipeline.dataTypes.date.formats.mapValues {
                sourceBundle.settings.dateFormatter($0)
            }
            let allFormatters = formatters.recursivelyMerged(
                with: pipelineFormatters
            )
            
            let contents = iteratorResolver.resolve(
                contents: sourceBundle.contents,
                using: pipeline
            )

            let lastUpdate =
                getLastContentUpdate(
                    contents: contents,
                    pipeline: pipeline
                ) ?? now

            let lastUpdateContext = lastUpdate.toDateFormats(
                formatters: allFormatters
            )
            siteContext["lastUpdate"] = .init(lastUpdateContext)

            let contextBundles = try getContextBundles(
                contents: contents,
                context: [
                    "site": .init(siteContext)
                ],
                pipeline: pipeline
            )

            switch pipeline.engine.id {
            case "json", "context":
                results += try renderAsJSON(
                    contextBundles: contextBundles
                )
            case "mustache":
                results += try renderAsHTML(
                    contextBundles: contextBundles,
                    pipeline: pipeline
                )
            default:
                logger.error(
                    "Unknown renderer engine `\(pipeline.engine.id)`."
                )
            }
        }
        return results
    }

    /// Returns the renderable context bundle for each content for a given pipeline using the global context
    mutating func getContextBundles(
        contents: [Content],
        context globalContext: [String: AnyCodable],
        pipeline: Pipeline
    ) throws -> [ContextBundle] {
        contents.compactMap { content in
            let isAllowed = pipeline.contentTypes.isAllowed(
                contentType: content.definition.id
            )
            guard isAllowed else {
                return nil
            }

            let pipelineContext = getPipelineContext(
                contents: contents,
                pipeline: pipeline,
                currentSlug: content.slug
            )
            .recursivelyMerged(with: globalContext)

            return getContextBundle(
                contents: contents,
                content: content,
                pipeline: pipeline,
                pipelineContext: pipelineContext
            )
        }
    }

    mutating func getPipelineContext(
        contents: [Content],
        pipeline: Pipeline,
        currentSlug: String
    ) -> [String: AnyCodable] {
        var rawContext: [String: AnyCodable] = [:]
        for (key, query) in pipeline.queries {
            let results = contents.run(query: query)

            rawContext[key] = .init(
                results.map {
                    getContentContext(
                        contents: contents,
                        for: $0,
                        pipeline: pipeline,
                        scopeKey: query.scope ?? "list",
                        currentSlug: currentSlug
                    )
                }
            )
        }
        return [
            "context": .init(rawContext)
        ]
    }

    mutating func getIteratorContext(
        contents: [Content],
        content: Content,
        pipeline: Pipeline
    ) -> [String: AnyCodable] {
        guard let iteratorInfo = content.iteratorInfo else {
            return [:]
        }
        let itemContext = iteratorInfo.items.map {
            getContentContext(
                contents: contents,
                for: $0,
                pipeline: pipeline,
                scopeKey: iteratorInfo.scope ?? "list",
                currentSlug: content.slug
            )
        }
        return [
            "iterator": .init(
                [
                    "total": .init(iteratorInfo.total),
                    "limit": .init(iteratorInfo.limit),
                    "current": .init(iteratorInfo.current),
                    "items": .init(itemContext),
                    "links": .init(iteratorInfo.links),
                ] as [String: AnyCodable]
            )
        ]
    }

    mutating func getContextBundle(
        contents: [Content],
        content: Content,
        pipeline: Pipeline,
        pipelineContext: [String: AnyCodable]
    ) -> ContextBundle {

        let pageContext = getContentContext(
            contents: contents,
            for: content,
            pipeline: pipeline,
            scopeKey: "detail",
            currentSlug: content.slug
        )

        let iteratorContext = getIteratorContext(
            contents: contents,
            content: content,
            pipeline: pipeline
        )

        let context: [String: AnyCodable] = [
            "page": .init(pageContext)
        ]
        .recursivelyMerged(with: iteratorContext)
        .recursivelyMerged(with: pipelineContext)

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

    mutating func getContentContext(
        contents: [Content],
        for content: Content,
        pipeline: Pipeline,
        scopeKey: String,
        currentSlug: String?,
        allowSubQueries: Bool = true  // allow top level queries only,
    ) -> [String: AnyCodable] {
        var result: [String: AnyCodable] = [:]
        
        let pipelineFormatters = pipeline.dataTypes.date.formats.mapValues {
            sourceBundle.settings.dateFormatter($0)
        }
        let allFormatters = formatters.recursivelyMerged(
            with: pipelineFormatters
        )
        
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

        if let cachedContext = contentContextCache[cacheKey] {
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
                        rawDate.toDateFormats(formatters: allFormatters)
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
                content.rawValue.lastModificationDate.toDateFormats(
                    formatters: allFormatters
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

                let relationContents = contents.run(
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
                        getContentContext(
                            contents: contents,
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
                let queryContents = contents.run(
                    query: query.resolveFilterParameters(
                        with: content.queryFields
                    )
                )

                result[key] = .init(
                    queryContents.map {
                        getContentContext(
                            contents: contents,
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
            contentContextCache[cacheKey] = result
            return result
        }
        contentContextCache[cacheKey] = result
        return result.filter { scope.fields.contains($0.key) }
    }

    // MARK: - rendering

    private func renderAsJSON(
        contextBundles: [ContextBundle]
    ) throws -> [PipelineResult] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .withoutEscapingSlashes,
            .sortedKeys,
        ]

        return try contextBundles.compactMap {
            // TODO: override output using front matter in both cases
            let data = try encoder.encode($0.context)
            let json = String(data: data, encoding: .utf8)
            guard let json else {
                // TODO: log
                return nil
            }
            return .init(
                contents: json,
                destination: $0.destination
            )
        }
    }

    private func renderAsHTML(
        contextBundles: [ContextBundle],
        pipeline: Pipeline
    ) throws -> [PipelineResult] {
        let renderer = MustacheTemplateRenderer(
            templates: try sourceBundle.templates.mapValues {
                try .init(string: $0)
            }
        )

        return try contextBundles.compactMap {
            let engineOptions = pipeline.engine.options
            let contentTypesOptions = engineOptions.dict("contentTypes")
            let bundleOptions = contentTypesOptions.dict(
                $0.content.definition.id
            )

            let contentTypeTemplate = bundleOptions.string("template")
            let contentTemplate = $0.content.rawValue.frontMatter
                .string("template")

            guard let template = contentTemplate ?? contentTypeTemplate
            else {
                // TODO: log
                return nil
            }

            let html = try renderer.render(
                template: template,
                with: $0.context
            )

            guard let html else {
                // TODO: log
                return nil
            }

            return .init(
                contents: html,
                destination: $0.destination
            )
        }
    }
}

extension SourceBundleRenderer {
    
    static func prepareFormatters(
        _ sourceBundle: SourceBundle
    ) -> [String: DateFormatter] {
        var formatters: [String: DateFormatter] = [:]
        let styles: [(String, DateFormatter.Style)] = [
            ("full", .full),
            ("long", .long),
            ("medium", .medium),
            ("short", .short),
        ]

        for (key, style) in styles {
            let dateFormatter = sourceBundle.settings.dateFormatter()
            dateFormatter.dateStyle = style
            dateFormatter.timeStyle = .none
            formatters["date.\(key)"] = dateFormatter

            let timeFormatter = sourceBundle.settings.dateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = style
            formatters["time.\(key)"] = timeFormatter
        }

        let standard: [String: LocalizedDateFormat] = [
            "iso8601": .init(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            "rss": .init(format: "EEE, dd MMM yyyy HH:mm:ss Z"),
            "sitemap": .init(format: "yyyy-MM-dd"),
        ]

        for (key, dateFormat) in standard.recursivelyMerged(
            with: sourceBundle.config.dateFormats.output
        ) {
            let formatter = sourceBundle.settings.dateFormatter()
            formatter.config(with: dateFormat)
            formatters[key] = formatter
        }
        return formatters
    }
}

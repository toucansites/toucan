//
//  BuildTargetSourceRenderer.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 25..
//

import Foundation
import Logging
import ToucanCore
import ToucanMarkdown
import ToucanSerialization
import ToucanSource

enum BuildTargetSourceRendererError: ToucanError {
    case invalidEngine(String)
    case unknown(Error)

    var underlyingErrors: [any Error] {
        switch self {
        case let .unknown(error):
            [error]
        default:
            []
        }
    }

    var logMessage: String {
        switch self {
        case let .invalidEngine(engine):
            "Invalid engine: `\(engine)`."
        case let .unknown(error):
            error.localizedDescription
        }
    }

    var userFriendlyMessage: String {
        switch self {
        case let .invalidEngine(engine):
            "Invalid engine: `\(engine)`."
        case .unknown:
            "Unknown source validator error."
        }
    }
}

/// Responsible for rendering the entire site bundle based on the `BuildTargetSource` configuration.
///
/// It processes content pipelines using the configured engine (Mustache, JSON, etc.),
/// resolves content and site-level context, and outputs rendered content using templates
/// or encoded formats.
public struct BuildTargetSourceRenderer {

    /// Site configuration + all raw content
    let buildTargetSource: BuildTargetSource
    /// Generator metadata (e.g., version, name)
    let generatorInfo: GeneratorInfo
    /// Logger for warnings and errors
    let logger: Logger
    /// Cache
    var contentContextCache: [String: [String: AnyCodable]] = [:]

    /// Initializes a renderer from a source bundle.
    ///
    /// - Parameters:
    ///   - buildTargetSource: The structured bundle containing settings, pipelines, and contents.
    ///   - templates: The template IDs and contents used by the Mustache renderer.
    ///   - generatorInfo: Info about the content generator (defaults to `.current`).
    ///   - logger: Logger for reporting issues or metrics.
    public init(
        buildTargetSource: BuildTargetSource,
        generatorInfo: GeneratorInfo = .current,
        logger: Logger = .subsystem("build-target-source-renderer")
    ) {
        self.buildTargetSource = buildTargetSource
        self.generatorInfo = generatorInfo
        self.logger = logger
    }

    /// Returns the last content update based on the pipeline config
    private func getLastContentUpdate(
        contents: [Content],
        pipeline: Pipeline,
        now: TimeInterval
    ) -> TimeInterval? {
        var updateTypes = Set(contents.map(\.type.id))
        if !pipeline.contentTypes.lastUpdate.isEmpty {
            updateTypes = updateTypes.filter {
                pipeline.contentTypes.lastUpdate.contains($0)
            }
        }
        let lastUpdate =
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
                    ),
                    now: now
                )
                return items.first?.rawValue.lastModificationDate
            }
            .sorted(by: >).first

        logger.trace(
            "Last update for the pipeline.",
            metadata: [
                "pipeline": .string(pipeline.id),
                "lastUpdate": .string(
                    Date(timeIntervalSince1970: lastUpdate ?? 0).description
                ),
            ]
        )

        return lastUpdate
    }

    private func baseURL() -> String {
        buildTargetSource.target.url.dropTrailingSlash()
    }

    /// Returns the renderable context bundle for each content for a given pipeline using the global context
    mutating func getContextBundles(
        contents: [Content],
        context globalContext: [String: AnyCodable],
        pipeline: Pipeline,
        dateFormatter: ToucanOutputDateFormatter,
        now: TimeInterval
    ) throws -> [ContextBundle] {
        contents.compactMap { content in
            let isAllowed = pipeline.contentTypes.isAllowed(
                contentType: content.type.id
            )
            guard isAllowed else {
                logger.trace(
                    "Skipping content type for the pipeline.",
                    metadata: [
                        "pipeline": .string(pipeline.id),
                        "content-type": .string(content.type.id),
                        "include": .array(
                            pipeline.contentTypes.include.map { .string($0) }
                        ),
                        "exclude": .array(
                            pipeline.contentTypes.exclude.map { .string($0) }
                        ),
                    ]
                )
                return nil
            }

            let pipelineContext = getPipelineContext(
                contents: contents,
                pipeline: pipeline,
                dateFormatter: dateFormatter,
                now: now
            )
            .recursivelyMerged(with: globalContext)

            return getContextBundle(
                contents: contents,
                content: content,
                pipeline: pipeline,

                pipelineContext: pipelineContext,
                dateFormatter: dateFormatter,
                now: now
            )
        }
    }

    mutating func getPipelineContext(
        contents: [Content],
        pipeline: Pipeline,
        dateFormatter: ToucanOutputDateFormatter,
        now: TimeInterval
    ) -> [String: AnyCodable] {
        var rawContext: [String: AnyCodable] = [:]
        for (key, query) in pipeline.queries {
            let results = contents.run(query: query, now: now)

            rawContext[key] = .init(
                results.map {
                    getContentContext(
                        contents: contents,
                        for: $0,
                        pipeline: pipeline,
                        dateFormatter: dateFormatter,
                        now: now,
                        scopeKey: query.scope ?? "list"
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
        pipeline: Pipeline,
        dateFormatter: ToucanOutputDateFormatter,
        now: TimeInterval
    ) -> [String: AnyCodable] {
        guard let iteratorInfo = content.iteratorInfo else {
            return [:]
        }
        let itemContext = iteratorInfo.items.map {
            getContentContext(
                contents: contents,
                for: $0,
                pipeline: pipeline,
                dateFormatter: dateFormatter,
                now: now,
                scopeKey: iteratorInfo.scope ?? "list"
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
        pipelineContext: [String: AnyCodable],
        dateFormatter: ToucanOutputDateFormatter,
        now: TimeInterval
    ) -> ContextBundle {
        let pageContext = getContentContext(
            contents: contents,
            for: content,
            pipeline: pipeline,
            dateFormatter: dateFormatter,
            now: now,
            scopeKey: "detail"
        )

        let iteratorContext = getIteratorContext(
            contents: contents,
            content: content,
            pipeline: pipeline,
            dateFormatter: dateFormatter,
            now: now
        )

        let context: [String: AnyCodable] = [
            "page": .init(pageContext)
        ]
        .recursivelyMerged(with: iteratorContext)
        .recursivelyMerged(with: pipelineContext)

        var outputArgs: [String: String] = [
            "{{id}}": content.typeAwareID,
            "{{slug}}": content.slug.value,
        ]

        if let info = content.iteratorInfo {
            outputArgs["{{iterator.current}}"] = String(info.current)
            outputArgs["{{iterator.total}}"] = String(info.total)
            outputArgs["{{iterator.limit}}"] = String(info.limit)
        }

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
        dateFormatter: ToucanOutputDateFormatter,
        now: TimeInterval,
        scopeKey: String,
        allowSubQueries: Bool = true  // allow top level queries only
    ) -> [String: AnyCodable] {
        var result: [String: AnyCodable] = [:]

        let scope = pipeline.getScope(
            keyedBy: scopeKey,
            for: content.type.id
        )

        logger.trace(
            "Using scope for content",
            metadata: [
                "pipeline": .string(pipeline.id),
                "content": .string(content.slug.value),
                "scope": .string(scopeKey),
                "context": .array(
                    scope.context.stringValues.map { .string($0) }
                ),
                "fields": .array(
                    scope.fields.map { .string($0) }
                ),
                "allowSubQueries": .string(allowSubQueries.description),
            ]
        )

        let cacheKey = [
            pipeline.id,
            content.slug.value,
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
                if let p = content.type.properties[k] {
                    switch p.type {
                    /// resolve assets
                    case .asset:
                        guard let rawValue = v.stringValue() else {
                            continue
                        }

                        let resolvedValue = rawValue.resolveAsset(
                            baseURL: baseURL(),
                            assetsPath: content.rawValue.assetsPath,
                            slug: content.slug.value
                        )

                        result[k] = .init(resolvedValue)
                    /// format dates
                    case .date:
                        guard let rawValue = v.doubleValue() else {
                            continue
                        }
                        result[k] = .init(
                            dateFormatter.format(rawValue)
                        )
                    default:
                        result[k] = .init(v.value)
                    }
                }
                else {
                    result[k] = .init(v.value)
                }
            }

            result["slug"] = .init(content.slug)
            result["permalink"] = .init(
                content.slug.permalink(baseURL: baseURL())
            )

            result["lastUpdate"] = .init(
                dateFormatter.format(content.rawValue.lastModificationDate)
            )
        }

        if scope.context.contains(.contents) {
            let transformers = pipeline.transformers[
                content.type.id
            ]
            let renderer = MarkdownRenderer(
                configuration: .init(
                    markdown: .init(
                        customBlockDirectives: buildTargetSource.blocks
                            .map {
                                .init(
                                    name: $0.name,
                                    parameters: $0.parameters?
                                        .map {
                                            .init(
                                                label: $0.label,
                                                isRequired: $0.isRequired,
                                                defaultValue: $0.defaultValue
                                            )
                                        },
                                    requiresParentDirective: $0
                                        .requiresParentDirective,
                                    removesChildParagraph: $0
                                        .removesChildParagraph,
                                    tag: $0.tag,
                                    attributes: $0.attributes?
                                        .map {
                                            .init(
                                                name: $0.name,
                                                value: $0.value
                                            )
                                        },
                                    output: $0.output
                                )
                            }
                    ),
                    outline: .init(
                        levels: buildTargetSource.config.renderer
                            .outlineLevels
                    ),
                    readingTime: .init(
                        wordsPerMinute: buildTargetSource.config
                            .renderer.wordsPerMinute
                    ),
                    transformerPipeline: transformers.map {
                        .init(
                            run: $0.run.map {
                                .init(path: $0.path, name: $0.name)
                            },
                            isMarkdownResult: $0.isMarkdownResult
                        )
                    },
                    paragraphStyles: buildTargetSource.config.renderer
                        .paragraphStyles.styles
                ),
                logger: logger
            )

            let contents = renderer.render(
                content: content.rawValue.markdown.contents,
                typeAwareID: content.typeAwareID,
                slug: content.slug.value,
                assetsPath: buildTargetSource.config.contents.assets.path,
                baseURL: baseURL()
            )

            result["contents"] = [
                "html": contents.html,
                "readingTime": contents.readingTime,
                "outline": contents.outline,
            ]
        }

        if scope.context.contains(.relations) {
            for (key, relation) in content.type.relations {
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
                    ),
                    now: now
                )

                let relationContexts = relationContents.map {
                    getContentContext(
                        contents: contents,
                        for: $0,
                        pipeline: pipeline,
                        dateFormatter: dateFormatter,
                        now: now,
                        scopeKey: "reference",
                        allowSubQueries: false
                    )
                }

                switch relation.type {
                case .many:
                    result[key] = .init(relationContexts)
                case .one:
                    if let item = relationContexts.first {
                        result[key] = .init(item)
                    }
                }
            }
        }

        if allowSubQueries, scope.context.contains(.queries) {
            for (key, query) in content.type.queries {
                let queryContents = contents.run(
                    query: query.resolveFilterParameters(
                        with: content.queryFields
                    ),
                    now: now
                )

                result[key] = .init(
                    queryContents.map {
                        getContentContext(
                            contents: contents,
                            for: $0,
                            pipeline: pipeline,
                            dateFormatter: dateFormatter,
                            now: now,
                            scopeKey: query.scope ?? "list",
                            allowSubQueries: false
                        )
                    }
                )
            }
        }

        logger.trace(
            "Returning context for content",
            metadata: [
                "pipeline": .string(pipeline.id),
                "content": .string(content.slug.value),
                "scope": .string(scopeKey),
                "context": .array(
                    scope.context.stringValues.map { .string($0) }
                ),
                "fields": .array(
                    scope.fields.map { .string($0) }
                ),
                "allowSubQueries": .string(allowSubQueries.description),
                "result": .dictionary(
                    [
                        "slug": .string(
                            result["slug"]?.stringValue() ?? "nil"
                        ),
                        "permalink": .string(
                            result["permalink"]?.stringValue() ?? "nil"
                        ),
                    ]
                ),
            ]
        )

        guard !scope.fields.isEmpty else {
            contentContextCache[cacheKey] = result
            return result
        }
        contentContextCache[cacheKey] = result
        return result.filter { scope.fields.contains($0.key) }
    }

    /// Starts rendering the source bundle based on current time and pipeline configuration.
    ///
    /// - Parameter now: Current date, used for generation timestamps.
    /// - Returns: A list of rendered `PipelineResult`s.
    /// - Throws: Rendering or encoding-related errors.
    public mutating func render(
        now: Date,
        rendererBlock: @escaping ((_ : Pipeline, _ : [ContextBundle]) throws -> [PipelineResult])
    ) throws -> [PipelineResult] {
        let now = now.timeIntervalSince1970

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let inputDateFormatter = ToucanInputDateFormatter(
            dateConfig: buildTargetSource.config.dataTypes.date,
            logger: logger
        )

        // TODO: This should be in a .toucaninfo file or similar
        let globalContext: [String: AnyCodable] = [
            "baseUrl": .init(baseURL()),
            "generator": .init(generatorInfo),
        ]

        let contentTypeResolver = ContentTypeResolver(
            types: buildTargetSource.types,
            pipelines: buildTargetSource.pipelines
        )

        let contentResolver = ContentResolver(
            contentTypeResolver: contentTypeResolver,
            encoder: encoder,
            decoder: decoder,
            dateFormatter: inputDateFormatter,
            logger: logger
        )

        let baseContents = try contentResolver.convert(
            rawContents: buildTargetSource.rawContents
        )

        var results: [PipelineResult] = []

        // TODO: `for` probably should happen in Toucan.swift, and we could deal with a single pipeline here
        for pipeline in buildTargetSource.pipelines {
            let filteredContents = contentResolver.apply(
                filterRules: pipeline.contentTypes.filterRules,
                to: baseContents,
                now: now
            )
            let iteratedContents = contentResolver.apply(
                iterators: pipeline.iterators,
                to: filteredContents,
                baseURL: baseURL(),
                now: now
            )

            let finalContents = try contentResolver.apply(
                assetProperties: pipeline.assets.properties,
                to: iteratedContents,
                contentsURL: buildTargetSource.locations.contentsURL,
                assetsPath: buildTargetSource.config.contents.assets.path,
                baseURL: baseURL()
            )

            let dateFormatter = ToucanOutputDateFormatter(
                dateConfig: buildTargetSource.config.dataTypes.date,
                pipelineDateConfig: pipeline.dataTypes.date,
                logger: logger
            )

            let assetResults = try contentResolver.applyBehaviors(
                pipeline: pipeline,
                to: finalContents,
                contentsURL: buildTargetSource.locations.contentsURL,
                assetsPath: buildTargetSource.config.contents.assets.path
            )

            results.append(contentsOf: assetResults)

            let lastUpdate =
                getLastContentUpdate(
                    contents: finalContents,
                    pipeline: pipeline,
                    now: now
                ) ?? now

            let contextBundles = try getContextBundles(
                contents: finalContents,
                context: globalContext.recursivelyMerged(
                    with: [
                        "lastUpdate": .init(dateFormatter.format(lastUpdate)),
                        "generation": .init(dateFormatter.format(now)),
                        "site": .init(buildTargetSource.settings.values),
                    ]
                ),
                pipeline: pipeline,
                dateFormatter: dateFormatter,
                now: now
            )

            logger.trace(
                "Rendering contents for pipeline",
                metadata: [
                    "pipeline": .string(pipeline.id),
                    "counts": [
                        "base": .string(baseContents.count.description),
                        "iterated": .string(iteratedContents.count.description),
                        "final": .string(finalContents.count.description),
                        "context": .string(contextBundles.count.description),
                    ],
                    "final": .array(
                        finalContents.map(\.slug.value).map { .string($0) }
                    ),
                    "context": .array(
                        contextBundles.map(
                            \.content.slug.value
                        )
                        .map { .string($0) }
                    ),
                ]
            )

            results += try rendererBlock(pipeline, contextBundles)
        }
        return results
    }
}

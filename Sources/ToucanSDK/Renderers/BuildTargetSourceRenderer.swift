//
//  BuildTargetSourceRenderer.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 25..
//

import Foundation

import ToucanMarkdown
import FileManagerKit
import Logging
import ToucanCore
import ToucanSource
import ToucanSerialization

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
    /// Date formatters used across pipelines
    /// File system abstraction
    let fileManager: FileManagerKit
    /// Logger for warnings and errors
    let logger: Logger
    /// Cache
    var contentContextCache: [String: [String: AnyCodable]] = [:]

    /// Initializes a renderer from a source bundle.
    ///
    /// - Parameters:
    ///   - buildTargetSource: The structured bundle containing settings, pipelines, and contents.
    ///   - generatorInfo: Info about the content generator (defaults to `.current`).
    ///   - fileManager: Filesystem API for use during rendering.
    ///   - logger: Logger for reporting issues or metrics.
    public init(
        buildTargetSource: BuildTargetSource,
        generatorInfo: GeneratorInfo = .current,
        fileManager: FileManagerKit,
        logger: Logger
    ) {
        self.buildTargetSource = buildTargetSource
        self.generatorInfo = generatorInfo
        self.fileManager = fileManager
        self.logger = logger
    }

    // MARK: -

    /// Returns the last content update based on the pipeline config
    private func getLastContentUpdate(
        contents: [Content],
        pipeline: Pipeline,
        now: TimeInterval
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
                    ),
                    now: now
                )
                return items.first?.rawValue.lastModificationDate
            }
            .sorted(by: >).first
    }

    /// Starts rendering the source bundle based on current time and pipeline configuration.
    ///
    /// - Parameter now: Current date, used for generation timestamps.
    /// - Returns: A list of rendered `PipelineResult`s.
    /// - Throws: Rendering or encoding-related errors.
    public mutating func render(
        now: Date
    ) throws -> [PipelineResult] {

        let now = now.timeIntervalSince1970

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let inputDateFormatter = ToucanInputDateFormatter(
            dateConfig: buildTargetSource.config.dataTypes.date,
            logger: logger
        )

        var siteContext = buildTargetSource.settings.values.recursivelyMerged(
            with: [
                "baseUrl": .init(buildTargetSource.target.url)
            ]
        )

        // TODO: This should be in a .toucaninfo file or similar
        siteContext["generator"] = .init(generatorInfo)
        siteContext["generatedAt"] = .init(
            inputDateFormatter.string(
                from: .init(
                    timeIntervalSince1970: now
                )
            )
        )

        let executor = AssetBehaviorExecutor(
            buildTargetSource: buildTargetSource
        )

        let contentTypeResolver = ContentTypeResolver(
            types: buildTargetSource.contentDefinitions,
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
        for pipeline in buildTargetSource.pipelines {

            let filteredContents = contentResolver.apply(
                filterRules: pipeline.contentTypes.filterRules,
                to: baseContents,
                now: now
            )
            let finalContents = contentResolver.apply(
                iterators: pipeline.iterators,
                to: filteredContents,
                now: now
            )

            let dateFormatter = ToucanOutputDateFormatter(
                dateConfig: buildTargetSource.config.dataTypes.date,
                pipelineDateConfig: pipeline.dataTypes.date,
                logger: logger
            )

            //
            //            let assetResults = try executor.execute(
            //                pipeline: pipeline,
            //                contents: contents
            //            )
            //            results.append(contentsOf: assetResults)
            //
            //            let assetPropertyResolver = AssetPropertyResolver(
            //                contentsUrl: buildTargetSource.sourceConfig.contentsUrl,
            //                assetsPath: buildTargetSource.sourceConfig.config.contents.assets
            //                    .path,
            //                baseUrl: buildTargetSource.baseUrl,
            //                config: pipeline.assets
            //            )
            //
            //            let finalContents = try assetPropertyResolver.resolve(contents)

            let lastUpdate =
                getLastContentUpdate(
                    contents: finalContents,
                    pipeline: pipeline,
                    now: now
                ) ?? now

            let lastUpdateContext = dateFormatter.format(lastUpdate)
            siteContext["lastUpdate"] = .init(lastUpdateContext)

            let contextBundles = try getContextBundles(
                contents: finalContents,
                context: [
                    "site": .init(siteContext)
                ],
                pipeline: pipeline,
                now: now
            )

            switch pipeline.engine.id {
            case "json", "context":
                let renderer = ContextBundleToJSONRenderer(
                    pipeline: pipeline,
                    logger: logger
                )
                results += renderer.render(contextBundles)

            case "mustache":

                let renderer = try ContextBundleToHTMLRenderer(
                    pipeline: pipeline,
                    templates: [:],
                    logger: logger
                )
                results += renderer.render(contextBundles)
            default:
                logger.error(
                    "Unknown renderer engine `\(pipeline.engine.id)`"
                )
            }
        }
        return results
    }

    /// Returns the renderable context bundle for each content for a given pipeline using the global context
    mutating func getContextBundles(
        contents: [Content],
        context globalContext: [String: AnyCodable],
        pipeline: Pipeline,
        now: TimeInterval
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
                now: now
            )
            .recursivelyMerged(with: globalContext)

            return getContextBundle(
                contents: contents,
                content: content,
                pipeline: pipeline,
                pipelineContext: pipelineContext,
                now: now
            )
        }
    }

    mutating func getPipelineContext(
        contents: [Content],
        pipeline: Pipeline,
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
        now: TimeInterval
    ) -> ContextBundle {

        let pageContext = getContentContext(
            contents: contents,
            for: content,
            pipeline: pipeline,
            now: now,
            scopeKey: "detail"
        )

        let iteratorContext = getIteratorContext(
            contents: contents,
            content: content,
            pipeline: pipeline,
            now: now
        )

        let context: [String: AnyCodable] = [
            "page": .init(pageContext)
        ]
        .recursivelyMerged(with: iteratorContext)
        .recursivelyMerged(with: pipelineContext)

        var outputArgs: [String: String] = [
            "{{id}}": content.id,
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
        now: TimeInterval,
        scopeKey: String,
        allowSubQueries: Bool = true  // allow top level queries only,
    ) -> [String: AnyCodable] {
        var result: [String: AnyCodable] = [:]

        let scope = pipeline.getScope(
            keyedBy: scopeKey,
            for: content.definition.id
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
                if let p = content.definition.properties[k],
                    case .date(_) = p.type,
                    let rawDate = v.value(as: Double.self)
                {
                    //                    result[k] = .init(
                    //                        rawDate.toDateFormats(formatters: allFormatters)
                    //                    )
                }
                else {
                    result[k] = .init(v.value)
                }
            }

            result["slug"] = .init(content.slug)
            result["permalink"] = .init(
                ""
                //                content.slug.permalink(baseUrl: buildTargetSource.target.url)
            )
            //            result["lastUpdate"] = .init(
            //                content.rawValue.lastModificationDate.toDateFormats(
            //                    formatters: allFormatters
            //                )
            //            )
        }

        if scope.context.contains(.contents) {
            let transformers = pipeline.transformers[
                content.definition.id
            ]
            let renderer = MarkdownRenderer(
                configuration: .init(
                    markdown: .init(
                        customBlockDirectives: []
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

                fileManager: fileManager,
                logger: logger
            )

            let contents = renderer.render(
                content: content.rawValue.markdown.contents,
                slug: content.slug.value,
                assetsPath: buildTargetSource.config.contents.assets.path,
                baseUrl: "buildTargetSource.baseUrl"
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
                    ),
                    now: now
                )
                result[key] = .init(
                    relationContents.map {
                        getContentContext(
                            contents: contents,
                            for: $0,
                            pipeline: pipeline,
                            now: now,
                            scopeKey: "reference",
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
                    ),
                    now: now
                )

                result[key] = .init(
                    queryContents.map {
                        getContentContext(
                            contents: contents,
                            for: $0,
                            pipeline: pipeline,
                            now: now,
                            scopeKey: query.scope ?? "list",
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
}

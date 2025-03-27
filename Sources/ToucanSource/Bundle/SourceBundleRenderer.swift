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

    var sourceBundle: SourceBundle
    let generator: Generator
    let dateFormatter: DateFormatter
    let fileManager: FileManagerKit
    let logger: Logger
    var contextCache: [String: [String: AnyCodable]] = [:]

    public init(
        sourceBundle: SourceBundle,
        generator: Generator = .v1_0_0_beta3,
        dateFormatter: DateFormatter,
        fileManager: FileManagerKit,
        logger: Logger
    ) {
        self.sourceBundle = sourceBundle
        self.generator = generator
        self.dateFormatter = dateFormatter
        self.fileManager = fileManager
        self.logger = logger
    }

    public mutating func renderPipelineResults(
        now: Date
    ) throws -> [PipelineResult] {
        let now = now.timeIntervalSince1970
        var results: [PipelineResult] = []

        var siteContext: [String: AnyCodable] = [
            "baseUrl": .init(sourceBundle.settings.baseUrl),
            "name": .init(sourceBundle.settings.name),
            "locale": .init(sourceBundle.settings.locale),
            "timeZone": .init(sourceBundle.settings.timeZone),
            "generation": .init(
                now.convertToDateFormats(
                    formatter: dateFormatter,
                    formats: sourceBundle.config.dateFormats.output
                )
            ),
            "generator": .init(Generator.v1_0_0_beta3),
        ]
        .recursivelyMerged(with: sourceBundle.settings.userDefined)

        for pipeline in sourceBundle.pipelines {

            var updateTypes = sourceBundle.contents.map(\.definition.id)
            if !pipeline.contentTypes.lastUpdate.isEmpty {
                updateTypes = updateTypes.filter {
                    pipeline.contentTypes.lastUpdate.contains($0)
                }
            }

            /// get last update date or use now as last update date.
            let lastUpdate: Double =
                updateTypes.compactMap {
                    let items = sourceBundle.run(
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

            let lastUpdateContext = lastUpdate.convertToDateFormats(
                formatter: dateFormatter,
                formats: sourceBundle.config.dateFormats.output
            )
            siteContext["lastUpdate"] = .init(lastUpdateContext)

            let contentIteratorResolver = ContentIteratorResolver()
            let bundles = try getContextBundles(
                finalContents: contentIteratorResolver.resolveContents(
                    sourceBundle: sourceBundle,
                    pipeline: pipeline
                ),
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
                    templates: try sourceBundle.templates.mapValues {
                        try .init(string: $0)
                    }
                )

                for bundle in bundles {
                    let engineOptions = pipeline.engine.options
                    let contentTypesOptions = engineOptions.dict("contentTypes")
                    let bundleOptions = contentTypesOptions.dict(
                        bundle.content.definition.id
                    )

                    let contentTypeTemplate = bundleOptions.string("template")
                    let contentTemplate = bundle.content.rawValue.frontMatter
                        .string("template")

                    guard let template = contentTemplate ?? contentTypeTemplate
                    else {
                        // TODO: log
                        continue
                    }

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

    mutating func getContextBundles(
        finalContents: [Content],
        siteContext: [String: AnyCodable],
        pipeline: Pipeline
    ) throws -> [ContextBundle] {

        // we need to do this, otherwise all queries will run on the original contents and use the original {{post.pagination}}
        sourceBundle.contents = finalContents

        var bundles: [ContextBundle] = []

        for content in sourceBundle.contents {

            let pipelineContext = getPipelineContext(
                for: pipeline,
                currentSlug: content.slug
            )
            .recursivelyMerged(with: siteContext)

            let isAllowed = pipeline.contentTypes.isAllowed(
                contentType: content.definition.id
            )

            guard isAllowed else {
                continue
            }

            let bundle = getContextBundle(
                content: content,
                using: pipeline,
                pipelineContext: pipelineContext
            )
            bundles.append(bundle)
        }
        return bundles
    }

}

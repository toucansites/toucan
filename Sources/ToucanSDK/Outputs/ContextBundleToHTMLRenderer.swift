//
//  ContextBundleToHTMLRenderer.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 05. 13..
//

import Foundation
import Logging
import ToucanSource

struct ContextBundleToHTMLRenderer {

    let mustacheRenderer: MustacheRenderer
    let engineContentTypesOptions: [String: AnyCodable]
    let pipelineViewKey: String
    let logger: Logger

    init(
        pipeline: Pipeline,
        templates: [String: String],
        logger: Logger
    ) throws {
        self.mustacheRenderer = try MustacheRenderer(
            templates: templates.mapValues {
                try .init(string: $0)
            },
            logger: logger
        )
        
        let engineOptions = pipeline.engine.options
        self.engineContentTypesOptions = engineOptions.dict("contentTypes")
        self.pipelineViewKey = ["views", pipeline.id].joined(separator: ".")
        self.logger = logger
    }

    func render(
        _ contextBundles: [ContextBundle]
    ) -> [PipelineResult] {
        contextBundles.compactMap { render($0) }
    }

    func render(
        _ contextBundle: ContextBundle
    ) -> PipelineResult? {
        let contentTypeOptions = engineContentTypesOptions.dict(
            contextBundle.content.type.id
        )
        let frontMatter = contextBundle.content.rawValue.markdown.frontMatter
        let contentTypeView = contentTypeOptions.string("view")
        let genericContentView = frontMatter.string("views.*")
        let contentView = frontMatter.string(pipelineViewKey)
        let viewId = contentView ?? genericContentView ?? contentTypeView

        guard let viewId, !viewId.isEmpty else {
            logger.warning(
                "No view has been specified for this content.",
                metadata: [
                    "slug": "\(contextBundle.content.slug)",
                    "type": "\(contextBundle.content.type.id)",
                ]
            )
            return nil
        }

        let html = mustacheRenderer.render(
            using: viewId,
            with: contextBundle.context
        )

        guard let html else {
            logger.warning(
                "Could not get valid HTML from content using view.",
                metadata: [
                    "slug": .string(contextBundle.content.slug.value),
                    "type": .string(contextBundle.content.type.id),
                    "view": .string(viewId),
                ]
            )
            return nil
        }

        return .init(
            source: .content(html),
            destination: contextBundle.destination
        )
    }
}

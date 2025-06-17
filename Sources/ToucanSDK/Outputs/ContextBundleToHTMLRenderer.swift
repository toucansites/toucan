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
    let mustacheTemplateRenderer: MustacheTemplateRenderer
    let contentTypesOptions: [String: AnyCodable]

    let logger: Logger

    init(
        pipeline: Pipeline,
        templates: [String: String],
        logger: Logger
    ) throws {
        self.mustacheTemplateRenderer = try MustacheTemplateRenderer(
            templates: templates.mapValues {
                try .init(string: $0)
            },
            logger: logger
        )
        self.contentTypesOptions = pipeline.engine.options.dict("contentTypes")
        self.logger = logger
    }

    func render(_ contextBundles: [ContextBundle]) -> [PipelineResult] {
        contextBundles.compactMap {
            render($0)
        }
    }

    func render(_ contextBundle: ContextBundle) -> PipelineResult? {
        let bundleOptions = contentTypesOptions.dict(
            contextBundle.content.type.id
        )

        let contentTypeTemplate = bundleOptions.string("template")
        let contentTemplate = contextBundle.content.rawValue.markdown
            .frontMatter
            .string("template")
        let template = contentTemplate ?? contentTypeTemplate

        guard let template, !template.isEmpty else {
            logger.warning(
                "Missing mustache template file.",
                metadata: [
                    "slug": "\(contextBundle.content.slug)",
                    "type": "\(contextBundle.content.type.id)",
                ]
            )
            return nil
        }

        let html = mustacheTemplateRenderer.render(
            template: template,
            with: contextBundle.context
        )

        guard let html, !html.isEmpty else {
            logger.warning(
                "Could not get valid HTML from content using template.",
                metadata: [
                    "slug": "\(contextBundle.content.slug)",
                    "type": "\(contextBundle.content.type.id)",
                    "template": "\(template)",
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

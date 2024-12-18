//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 13..
//

import Foundation
import Logging

struct RSSRenderer {

    let source: Source
    let destinationUrl: URL
    let fileManager: FileManager
    let templateRenderer: MustacheToHTMLRenderer
    let pageBundles: [PageBundle]
    let logger: Logger

    let contextStore: ContextStore

    init(
        source: Source,
        destinationUrl: URL,
        fileManager: FileManager,
        templateRenderer: MustacheToHTMLRenderer,
        pageBundles: [PageBundle],
        logger: Logger
    ) {
        self.source = source
        self.destinationUrl = destinationUrl
        self.fileManager = fileManager
        self.templateRenderer = templateRenderer
        self.pageBundles = pageBundles
        self.logger = logger

        self.contextStore = .init(
            sourceConfig: source.sourceConfig,
            contentTypes: source.contentTypes,
            pageBundles: source.pageBundles,
            blockDirectives: source.blockDirectives,
            logger: logger
        )
    }

    func render() throws {
        guard !pageBundles.isEmpty else {
            return
        }

        let items: [RSSContext.Item] =
            pageBundles
            .map { item in
                .init(
                    permalink: item.permalink,
                    title: item.title,
                    description: item.description,
                    publicationDate: item.date.rss,
                    userDefined: contextStore.fullContext(for: item)
                )
            }

        let rssDateFormatter = DateFormatters.rss

        let publicationDate =
            items.first?.publicationDate
            ?? rssDateFormatter.string(from: .init())

        let rssCtx = RSSContext(
            title: source.sourceConfig.site.title,
            description: source.sourceConfig.site.description,
            baseUrl: source.sourceConfig.site.baseUrl,
            language: source.sourceConfig.site.language,
            lastBuildDate: rssDateFormatter.string(from: .init()),
            publicationDate: publicationDate,
            items: items,
            userDefined: source.sourceConfig.site.userDefined
        )

        try templateRenderer.render(
            template: "rss",
            with: rssCtx.context,
            to:
                destinationUrl
                .appendingPathComponent(
                    source.sourceConfig.config.contents.rss.output
                )
        )
    }
}

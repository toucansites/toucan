import Foundation
import ToucanModels
import ToucanContent
import ToucanSource
import Logging

public extension SourceBundle.Mocks {

    static func complete(
        pipelines: [Pipeline] = [
            Pipeline.Mocks.context(),
            Pipeline.Mocks.html(),
            Pipeline.Mocks.rss(),
            Pipeline.Mocks.sitemap(),
            Pipeline.Mocks.redirect(),
        ]
    ) -> SourceBundle {
        let logger = Logger(label: "SourceBundleMocks")

        let settings = Settings.defaults
        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )
        let formatter = settings.dateFormatter(
            sourceConfig.config.dateFormats.input
        )

        // pages
        let pageDefinition = ContentDefinition.Mocks.page()
        let rawPageContents = RawContent.Mocks.pages()
        let pageContents = rawPageContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: pageDefinition,
                dateFormatter: formatter,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // categories
        let categoryDefinition = ContentDefinition.Mocks.category()
        let rawCategoryContents = RawContent.Mocks.categories()
        let categoryContents = rawCategoryContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: categoryDefinition,
                dateFormatter: formatter,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // guides
        let guideDefinition = ContentDefinition.Mocks.guide()
        let rawGuideContents = RawContent.Mocks.guides()
        let guideContents = rawGuideContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: guideDefinition,
                dateFormatter: formatter,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // tags
        let tagDefinition = ContentDefinition.Mocks.tag()
        let rawTagContents = RawContent.Mocks.tags()
        let tagContents = rawTagContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: tagDefinition,
                dateFormatter: formatter,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // authors
        let authorDefinition = ContentDefinition.Mocks.author()
        let rawAuthorContents = RawContent.Mocks.authors()
        let authorContents = rawAuthorContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: authorDefinition,
                dateFormatter: formatter,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // posts
        let postDefinition = ContentDefinition.Mocks.post()
        let rawPostContents = RawContent.Mocks.posts(formatter: formatter)
        let postContents = rawPostContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: postDefinition,
                dateFormatter: formatter,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // rss
        let rssDefinition = ContentDefinition.Mocks.rss()
        let rawRSSContents = RawContent.Mocks.rss()
        let rssContents = rawRSSContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: rssDefinition,
                dateFormatter: formatter,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // sitemap
        let sitemapDefinition = ContentDefinition.Mocks.sitemap()
        let rawSitemapContents = RawContent.Mocks.sitemap()
        let sitemapContents = rawSitemapContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: sitemapDefinition,
                dateFormatter: formatter,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // redirects
        let redirectDefinition = ContentDefinition.Mocks.redirect()
        let rawRedirectContents = RawContent.Mocks.redirectHomeOldAboutOld()
        let redirectContents = rawRedirectContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: redirectDefinition,
                dateFormatter: formatter,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // block directives
        let blockDirectives = MarkdownBlockDirective.Mocks.highlightedTexts()

        let contents =
            pageContents + categoryContents + guideContents + tagContents
            + authorContents + postContents + rssContents + sitemapContents
            + redirectContents

        // TODO: add support for multiple engines: [mustache: [foo: tpl1]]

        let templates: [String: String] = [
            "default": Templates.Mocks.default(),
            "post.default": Templates.Mocks.post(),
            "rss": Templates.Mocks.rss(),
            "sitemap": Templates.Mocks.sitemap(),
            "redirect": Templates.Mocks.redirect(),
        ]

        return .init(
            location: .init(filePath: ""),
            config: config,
            sourceConfig: sourceConfig,
            settings: settings,
            pipelines: pipelines,
            contents: contents,
            blockDirectives: blockDirectives,
            templates: templates,
            baseUrl: ""
        )
    }
}

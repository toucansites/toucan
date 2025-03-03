import Foundation
import ToucanModels
import ToucanSource

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

        let formatter = DateFormatter()
        // pages
        let pageDefinition = ContentDefinition.Mocks.page()
        let rawPageContents = RawContent.Mocks.pages()
        let pageContents = rawPageContents.map {
            pageDefinition.convert(rawContent: $0, using: formatter)
        }

        // categories
        let categoryDefinition = ContentDefinition.Mocks.category()
        let rawCategoryContents = RawContent.Mocks.categories()
        let categoryContents = rawCategoryContents.map {
            categoryDefinition.convert(rawContent: $0, using: formatter)
        }

        // guides
        let guideDefinition = ContentDefinition.Mocks.guide()
        let rawGuideContents = RawContent.Mocks.guides()
        let guideContents = rawGuideContents.map {
            guideDefinition.convert(rawContent: $0, using: formatter)
        }

        // tags
        let tagDefinition = ContentDefinition.Mocks.tag()
        let rawTagContents = RawContent.Mocks.tags()
        let tagContents = rawTagContents.map {
            tagDefinition.convert(rawContent: $0, using: formatter)
        }

        // authors
        let authorDefinition = ContentDefinition.Mocks.author()
        let rawAuthorContents = RawContent.Mocks.authors()
        let authorContents = rawAuthorContents.map {
            authorDefinition.convert(rawContent: $0, using: formatter)
        }

        // posts
        let postDefinition = ContentDefinition.Mocks.post()
        let rawPostContents = RawContent.Mocks.posts(
            formatter: formatter
        )
        let postContents = rawPostContents.map {
            postDefinition.convert(rawContent: $0, using: formatter)
        }

        // rss
        let rssDefinition = ContentDefinition.Mocks.rss()
        let rawRSSContents = RawContent.Mocks.rss()
        let rssContents = rawRSSContents.map {
            rssDefinition.convert(rawContent: $0, using: formatter)
        }

        // sitemap
        let sitemapDefinition = ContentDefinition.Mocks.sitemap()
        let rawSitemapContents = RawContent.Mocks.sitemap()
        let sitemapContents = rawSitemapContents.map {
            sitemapDefinition.convert(rawContent: $0, using: formatter)
        }

        // redirects
        let redirectDefinition = ContentDefinition.Mocks.redirect()
        let rawRedirectContents = RawContent.Mocks.redirectHomeOldAboutOld()
        let redirectContents = rawRedirectContents.map {
            redirectDefinition.convert(rawContent: $0, using: formatter)
        }

        let contents =
            pageContents +
            categoryContents +
            guideContents +
            tagContents +
            authorContents +
            postContents +
            rssContents +
            sitemapContents +
            redirectContents

        return .init(
            location: .init(filePath: ""),
            config: .defaults,
            settings: .defaults,
            pipelines: pipelines,
            contents: contents
        )
    }
}

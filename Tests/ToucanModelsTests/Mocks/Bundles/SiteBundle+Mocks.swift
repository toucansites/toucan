import Foundation
import ToucanModels

extension SiteBundle.Mocks {

    static func complete() -> SiteBundle {

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
        let rawPostContents = RawContent.Mocks.posts()
        let postContents = rawPostContents.map {
            postDefinition.convert(rawContent: $0, using: formatter)
        }

        let contentBundles: [ContentBundle] = [
            .init(definition: pageDefinition, contents: pageContents),
            .init(definition: categoryDefinition, contents: categoryContents),
            .init(definition: guideDefinition, contents: guideContents),
            .init(definition: tagDefinition, contents: tagContents),
            .init(definition: authorDefinition, contents: authorContents),
            .init(definition: postDefinition, contents: postContents),
        ]

        return .init(contentBundles: contentBundles)
    }
}

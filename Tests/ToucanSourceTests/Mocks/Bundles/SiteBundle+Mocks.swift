import Foundation
import ToucanModels
import ToucanSource

extension SourceBundle.Mocks {

    static func complete() -> SourceBundle {

        let formatter = DateFormatter()
        // pages
        let pageDefinition = ContentDefinition.Mocks.page()
        let rawPageContents = RawContent.Mocks.pages()
        let pageContents = rawPageContents.map {
            pageDefinition.convert(
                rawContent: $0,
                definition: pageDefinition,
                using: formatter
            )
        }

        // categories
        let categoryDefinition = ContentDefinition.Mocks.category()
        let rawCategoryContents = RawContent.Mocks.categories()
        let categoryContents = rawCategoryContents.map {
            categoryDefinition.convert(
                rawContent: $0,
                definition: categoryDefinition,
                using: formatter
            )
        }

        // guides
        let guideDefinition = ContentDefinition.Mocks.guide()
        let rawGuideContents = RawContent.Mocks.guides()
        let guideContents = rawGuideContents.map {
            guideDefinition.convert(
                rawContent: $0,
                definition: guideDefinition,
                using: formatter
            )
        }

        // tags
        let tagDefinition = ContentDefinition.Mocks.tag()
        let rawTagContents = RawContent.Mocks.tags()
        let tagContents = rawTagContents.map {
            tagDefinition.convert(
                rawContent: $0,
                definition: tagDefinition,
                using: formatter
            )
        }

        // authors
        let authorDefinition = ContentDefinition.Mocks.author()
        let rawAuthorContents = RawContent.Mocks.authors()
        let authorContents = rawAuthorContents.map {
            authorDefinition.convert(
                rawContent: $0,
                definition: authorDefinition,
                using: formatter
            )
        }

        // posts
        let postDefinition = ContentDefinition.Mocks.post()
        let rawPostContents = RawContent.Mocks.posts()
        let postContents = rawPostContents.map {
            postDefinition.convert(
                rawContent: $0,
                definition: postDefinition,
                using: formatter
            )
        }

        let contentBundles: [ContentBundle] = [
            .init(definition: pageDefinition, contents: pageContents),
            .init(definition: categoryDefinition, contents: categoryContents),
            .init(definition: guideDefinition, contents: guideContents),
            .init(definition: tagDefinition, contents: tagContents),
            .init(definition: authorDefinition, contents: authorContents),
            .init(definition: postDefinition, contents: postContents),
        ]

        let pipelines = RenderPipeline.Mocks.defaults()

        return .init(
            location: .init(filePath: ""),
            renderPipelines: pipelines,
            contentBundles: contentBundles
        )
    }
}

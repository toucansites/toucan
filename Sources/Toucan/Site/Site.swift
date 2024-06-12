//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation
import Algorithms

struct Site {

    enum Error: Swift.Error {
        case missingPage(String)
    }

    enum ImageVariant {
        case light
        case dark
    }

    struct State {

        struct Blog {
            struct Author {
                let list: AuthorListHTMLPageState
                let details: [AuthorDetailHTMLPageState]
            }

            struct Tag {
                let list: TagListHTMLPageState
                let details: [TagDetailHTMLPageState]
            }

            struct Post {
                let pages: [PostListHTMLPageState]
                let details: [PostDetailHTMLPageState]
            }

            let home: BlogHTMLPageState
            let post: Post
            let tag: Tag
            let author: Author
        }

        let home: HomeHTMLPageState
        let notFound: NotFoundHTMLPageState
        let blog: Blog
        let pages: [PageDetailHTMLPageState]
        let rss: RSSState
        let sitemap: SitemapState
    }

    let content: Content
    let assets: [String: String]

    let currentYear: Int
    let dateFormatter: DateFormatter
    let rssDateFormatter: DateFormatter
    let sitemapDateFormatter: DateFormatter

    init(
        content: Content,
        assets: [String: String]
    ) {
        self.content = content
        self.assets = assets

        let calendar = Calendar(identifier: .gregorian)
        self.currentYear = calendar.component(.year, from: .init())

        self.dateFormatter = DateFormatters.baseFormatter
        self.dateFormatter.dateFormat = content.config.site.dateFormat
        self.rssDateFormatter = DateFormatters.rss
        self.sitemapDateFormatter = DateFormatters.sitemap
    }

    // MARK: -

    func metadata(
        for content: ContentInterface
    ) -> MetadataState {
        .init(
            permalink: permalink(content.slug),
            title: content.title,
            description: content.description,
            imageUrl: assetUrl(
                for: content.coverImage,
                folder: type(of: content).folder
            )
        )
    }

    func render(
        markdown: String,
        folder: String
    ) -> String {
        let renderer = MarkdownToHTMLRenderer(
            delegate: HTMLRendererDelegate(
                site: self,
                folder: folder
            )
        )
        return renderer.render(markdown: markdown)
    }

    func readingTime(_ value: String) -> Int {
        value.split(separator: " ").count / 238
    }

    // MARK: - config

    func siteState(
        for config: Content.Config
    ) -> SiteState {
        .init(
            baseUrl: config.site.baseUrl,
            title: config.site.title,
            description: config.site.description,
            language: config.site.language
        )
    }

    // MARK: - content states

    func authorState(
        for author: Content.Author
    ) -> AuthorState {
        .init(
            permalink: permalink(author.slug),
            title: author.title,
            description: author.description,
            figure: figureState(
                for: author.coverImage,
                folder: Content.Author.folder
            ),
            numberOfPosts: content.blog.post.contentsBy(authorSlug: author.slug).count,
            userDefined: author.userDefined,
            markdown: render(
                        markdown: author.markdown,
                        folder: Content.Author.folder
                    )
        )
    }
    
    

    func tagState(
        for tag: Content.Tag
    ) -> TagState {
        .init(
            permalink: permalink(tag.slug),
            title: tag.title,
            description: tag.description,
            figure: figureState(
                for: tag.coverImage,
                folder: Content.Tag.folder
            ),
            numberOfPosts: content.blog.post.contentsBy(tagSlug: tag.slug).count,
            userDefined: tag.userDefined
        )
    }

    func pageState(
        for page: Content.Page
    ) -> PageState {
        .init(
            permalink: permalink(page.slug),
            title: page.title,
            description: page.description,
            figure: figureState(
                for: page.coverImage,
                folder: Content.Page.folder
            ),
            userDefined: page.userDefined
        )
    }

    func postState(
        for post: Content.Post,
        authors: [Content.Author],
        tags: [Content.Tag]
    ) -> PostState {
        return .init(
            permalink: permalink(post.slug),
            title: post.title,
            excerpt: post.description,
            date: dateFormatter.string(from: post.publication),
            figure: figureState(
                for: post.coverImage,
                folder: Content.Post.folder
            ),
            tags: tags.map { tagState(for: $0) },
            authors: authors.map { authorState(for: $0) },
            readingTime: readingTime(post.markdown),
            featured: post.featured,
            userDefined: post.userDefined
        )
    }

    // MARK: - list states

    func tagListState() -> [TagState] {
        content.blog.tag.contents
            .sorted { $0.title > $1.title }
            .map { tagState(for: $0) }
    }

    func authorListState() -> [AuthorState] {
        content.blog.author.contents
            .sorted { $0.title > $1.title }
            .map { authorState(for: $0) }
    }

    func postListState() -> [PostState] {
        content.blog.post.sortedContents.map {
            postState(
                for: $0,
                authors: content.blog.author.contentsBy(slugs: $0.authorSlugs),
                tags: content.blog.tag.contentsBy(slugs: $0.tagSlugs)
            )
        }
    }

    func featuredPostListState() -> [PostState] {
        content.blog.post.sortedContents
            .filter { $0.featured }
            .map {
                postState(
                    for: $0,
                    authors: content.blog.author.contentsBy(slugs: $0.authorSlugs),
                    tags: content.blog.tag.contentsBy(slugs: $0.tagSlugs)
                )
            }
    }

    func postListState(authorSlug: String) -> [PostState] {
        content.blog.post.contentsBy(authorSlug: authorSlug)
            .map {
                postState(
                    for: $0,
                    authors: content.blog.author.contentsBy(slugs: $0.authorSlugs),
                    tags: content.blog.tag.contentsBy(slugs: $0.tagSlugs)
                )
            }
    }

    func postListState(tagSlug: String) -> [PostState] {
        content.blog.post.contentsBy(tagSlug: tagSlug)
            .map {
                postState(
                    for: $0,
                    authors: content.blog.author.contentsBy(slugs: $0.authorSlugs),
                    tags: content.blog.tag.contentsBy(slugs: $0.tagSlugs)
                )
            }
    }

    // MARK: - system page states

    func home() -> HomeHTMLPageState {
        let homePage = content.home
        return .init(
            site: siteState(for: content.config),
            page: .init(
                slug: homePage.slug,
                metadata: metadata(for: homePage),
                context: .init(
                    featured: featuredPostListState(),
                    posts: Array(postListState().prefix(5)),
                    authors: Array(authorListState().prefix(5)),
                    tags: Array(tagListState().prefix(5)),
                    pages: content.custom.pages.map { pageState(for: $0) }
                ),
                content: render(
                    markdown: homePage.markdown,
                    folder: Content.Page.folder
                )
            ),
            userDefined: content.config.site.userDefined + homePage.userDefined,
            year: currentYear,
            template: homePage.template ?? "pages.home"
        )
    }

    func notFound() -> NotFoundHTMLPageState {
        let notFoundPage = content.notFound
        return .init(
            site: siteState(for: content.config),
            page: .init(
                slug: notFoundPage.slug,
                metadata: metadata(for: notFoundPage),
                context: .init(),
                content: render(
                    markdown: notFoundPage.markdown,
                    folder: Content.Page.folder
                )
            ),
            userDefined: content.config.site.userDefined
                + notFoundPage.userDefined,
            year: currentYear,
            template: notFoundPage.template ?? "pages.404"
        )
    }

    // MARK: - blog

    func blogPage() -> BlogHTMLPageState {
        let blogPage = content.blog.home
        return .init(
            site: siteState(for: content.config),
            page: .init(
                slug: blogPage.slug,
                metadata: metadata(for: blogPage),
                context: .init(
                    featured: featuredPostListState(),
                    posts: postListState(),
                    authors: authorListState(),
                    tags: tagListState()
                ),
                content: render(
                    markdown: blogPage.markdown,
                    folder: Content.Page.folder
                )
            ),
            userDefined: content.config.site.userDefined + blogPage.userDefined,
            year: currentYear,
            template: blogPage.template ?? "pages.blog.home"
        )
    }

    func authorList() -> AuthorListHTMLPageState {
        let authorsPage = content.blog.author.home
        return .init(
            site: siteState(for: content.config),
            page: .init(
                slug: authorsPage.slug,
                metadata: metadata(for: authorsPage),
                context: .init(
                    authors: authorListState()
                ),
                content: render(
                    markdown: authorsPage.markdown,
                    folder: Content.Page.folder
                )
            ),
            userDefined: content.config.site.userDefined
                + authorsPage.userDefined,
            year: currentYear,
            template: authorsPage.template ?? "pages.blog.authors"
        )
    }

    func tagList() -> TagListHTMLPageState {
        let tagsPage = content.blog.tag.home
        return .init(
            site: siteState(for: content.config),
            page: .init(
                slug: tagsPage.slug,
                metadata: metadata(for: tagsPage),
                context: .init(
                    tags: tagListState()
                ),
                content: render(
                    markdown: tagsPage.markdown,
                    folder: Content.Page.folder
                )
            ),
            userDefined: content.config.site.userDefined + tagsPage.userDefined,
            year: currentYear,
            template: tagsPage.template ?? "pages.blog.tags"
        )
    }

    func postListPages() -> [PostListHTMLPageState] {
        let postsPage = content.blog.post.home
        let pageLimit = content.config.blog.posts.page.limit
        let pages = content.blog.post.sortedContents.chunks(ofCount: pageLimit)

        func replace(
            _ number: Int,
            _ value: String
        ) -> String {
            value.replacingOccurrences(
                of: "{{number}}",
                with: String(number)
            )
        }

        var result: [PostListHTMLPageState] = []
        for (index, posts) in pages.enumerated() {
            let pageNumber = index + 1

            let title = replace(pageNumber, postsPage.title)
            let description = replace(pageNumber, postsPage.description)
            let slug = replace(pageNumber, postsPage.slug)

            let state: PostListHTMLPageState = .init(
                site: siteState(
                    for: content.config
                ),
                page: .init(
                    slug: slug,
                    metadata: .init(
                        permalink: permalink(slug),
                        title: title,
                        description: description,
                        imageUrl: assetUrl(
                            for: postsPage.coverImage,
                            folder: Content.Page.folder
                        )
                    ),
                    context: .init(
                        posts: posts.map {
                            postState(
                                for: $0,
                                authors: content.blog.author.contentsBy(
                                    slugs: $0.authorSlugs
                                ),
                                tags: content.blog.tag.contentsBy(
                                    slugs: $0.tagSlugs
                                )
                            )
                        },
                        pagination: (1...pages.count)
                            .map {
                                .init(
                                    number: $0,
                                    total: pages.count,
                                    slug: replace($0, postsPage.slug),
                                    permalink: permalink(
                                        replace($0, postsPage.slug)
                                    ),
                                    isCurrent: pageNumber == $0
                                )
                            }
                    ),
                    content: render(
                        markdown: postsPage.markdown,
                        folder: Content.Page.folder
                    )
                ),
                userDefined: content.config.site.userDefined
                    + postsPage.userDefined,
                year: currentYear,
                template: postsPage.template ?? "pages.blog.posts"
            )

            result.append(state)
        }

        return result
    }

    // MARK: - detail page states

    func authorDetails() -> [AuthorDetailHTMLPageState] {
        content.blog.author.contents.map {
            .init(
                site: siteState(for: content.config),
                page: .init(
                    slug: $0.slug,
                    metadata: metadata(for: $0),
                    context: .init(
                        author: authorState(for: $0),
                        posts: postListState(authorSlug: $0.slug)
                    ),
                    content: render(
                        markdown: $0.markdown,
                        folder: Content.Author.folder
                    )
                ),
                userDefined: content.config.site.userDefined + $0.userDefined,
                year: currentYear,
                template: $0.template ?? "pages.single.author"
            )
        }
    }

    func tagDetails() -> [TagDetailHTMLPageState] {
        content.blog.tag.contents.map {
            .init(
                site: siteState(for: content.config),
                page: .init(
                    slug: $0.slug,
                    metadata: metadata(for: $0),
                    context: .init(
                        tag: tagState(for: $0),
                        posts: postListState(tagSlug: $0.slug)
                    ),
                    content: render(
                        markdown: $0.markdown,
                        folder: Content.Tag.folder
                    )
                ),
                userDefined: content.config.site.userDefined + $0.userDefined,
                year: currentYear,
                template: $0.template ?? "pages.single.tag"
            )
        }
    }

    func nextPost(for slug: String) -> PostState? {
        let posts = content.blog.post.sortedContents

        if let index = posts.firstIndex(where: { $0.slug == slug }) {
            if index > 0 {
                let post = posts[index - 1]
                return postState(
                    for: post,
                    authors: content.blog.author.contentsBy(
                        slugs: post.authorSlugs
                    ),
                    tags: content.blog.tag.contentsBy(
                        slugs: post.tagSlugs
                    )
                )
            }
        }
        return nil
    }

    func prevPost(for slug: String) -> PostState? {
        let posts = content.blog.post.sortedContents

        if let index = posts.firstIndex(where: { $0.slug == slug }) {
            if index < posts.count - 1 {
                let post = posts[index + 1]
                return postState(
                    for: post,
                    authors: content.blog.author.contentsBy(
                        slugs: post.authorSlugs
                    ),
                    tags: content.blog.tag.contentsBy(
                        slugs: post.tagSlugs
                    )
                )
            }
        }
        return nil
    }

    func relatedPosts(for slug: String) -> [PostState] {
        var result: [PostState] = []

        let posts = content.blog.post.sortedContents
        if let index = posts.firstIndex(where: { $0.slug == slug }) {
            let post = posts[index]
            for tagSlug in post.tagSlugs {
                result += content.blog.post.contentsBy(tagSlug: tagSlug)
                    .filter { $0.slug != slug }
                    .map {
                        postState(
                            for: $0,
                            authors: content.blog.author.contentsBy(
                                slugs: $0.authorSlugs
                            ),
                            tags: content.blog.tag.contentsBy(
                                slugs: $0.tagSlugs
                            )
                        )
                    }
            }
        }
        return Array(result.shuffled().prefix(5))
    }

    func moreByPosts(for slug: String) -> [PostState] {
        var result: [PostState] = []

        let posts = content.blog.post.sortedContents
        if let index = posts.firstIndex(where: { $0.slug == slug }) {
            let post = posts[index]
            for authorSlug in post.authorSlugs {
                result += content.blog.post.contentsBy(authorSlug: authorSlug)
                    .filter { $0.slug != slug }
                    .map {
                        postState(
                            for: $0,
                            authors: content.blog.author.contentsBy(
                                slugs: $0.authorSlugs
                            ),
                            tags: content.blog.tag.contentsBy(
                                slugs: $0.tagSlugs
                            )
                        )
                    }
            }
        }
        return Array(result.shuffled().prefix(5))
    }

    func postDetails() -> [PostDetailHTMLPageState] {
        content.blog.post.contents.map {
            .init(
                site: siteState(for: content.config),
                page: .init(
                    slug: $0.slug,
                    metadata: metadata(for: $0),
                    context: .init(
                        post: postState(
                            for: $0,
                            authors: content.blog.author.contentsBy(
                                slugs: $0.authorSlugs
                            ),
                            tags: content.blog.tag.contentsBy(
                                slugs: $0.tagSlugs
                            )
                        ),
                        related: relatedPosts(for: $0.slug),
                        moreByAuthor: moreByPosts(for: $0.slug),
                        next: nextPost(for: $0.slug),
                        prev: prevPost(for: $0.slug)
                    ),
                    content: render(
                        markdown: $0.markdown,
                        folder: Content.Post.folder
                    )
                ),
                userDefined: content.config.site.userDefined + $0.userDefined,
                year: currentYear,
                template: $0.template ?? "pages.single.post"
            )
        }
    }

    func pages() -> [PageDetailHTMLPageState] {
        content.custom.pages.map {
            .init(
                site: siteState(for: content.config),
                page: .init(
                    slug: $0.slug,
                    metadata: metadata(for: $0),
                    context: .init(
                        permalink: permalink($0.slug),
                        title: $0.title,
                        description: $0.description,
                        figure: figureState(
                            for: $0.coverImage,
                            folder: Content.Page.folder
                        ),
                        userDefined: $0.userDefined
                    ),
                    content: render(
                        markdown: $0.markdown,
                        folder: Content.Page.folder
                    )
                ),
                userDefined: content.config.site.userDefined + $0.userDefined,
                year: currentYear,
                template: $0.template ?? "pages.single.page"
            )
        }
    }

    // MARK: - rss

    func rss() -> RSSState {
        let items: [RSSState.ItemState] = content.blog.post.sortedContents.map {
            .init(
                permalink: permalink($0.slug),
                title: $0.title,
                description: $0.description,
                publicationDate: rssDateFormatter.string(
                    from: $0.publication
                )
            )
        }
        return .init(
            title: content.config.site.title,
            description: content.config.site.description,
            baseUrl: content.config.site.baseUrl,
            language: content.config.site.language,
            lastBuildDate: rssDateFormatter.string(
                from: .init()
            ),
            publicationDate:
                items.first?.publicationDate
                ?? rssDateFormatter.string(
                    from: .init()
                ),
            items: items
        )
    }

    // MARK: - sitemap

    func sitemap() -> SitemapState {
        .init(
            urls: content.siteContents.map {
                .init(
                    location: permalink($0.slug),
                    lastModification: sitemapDateFormatter.string(
                        from: $0.lastModification
                    )
                )
            }
        )
    }

    // MARK: - build entire site state

    func buildState() -> State {
        .init(
            home: home(),
            notFound: notFound(),
            blog: .init(
                home: blogPage(),
                post: .init(
                    pages: postListPages(),
                    details: postDetails()
                ),
                tag: .init(
                    list: tagList(),
                    details: tagDetails()
                ),
                author: .init(
                    list: authorList(),
                    details: authorDetails()
                )
            ),
            pages: pages(),
            rss: rss(),
            sitemap: sitemap()
        )
    }

    // MARK: - helpers

    func permalink(_ value: String) -> String {
        let components = value.split(separator: "/").map(String.init)
        if components.isEmpty {
            return content.config.site.baseUrl
        }
        if components.last?.split(separator: ".").count ?? 0 > 1 {
            return content.config.site.baseUrl
                + components.joined(separator: "/")
        }
        return content.config.site.baseUrl + components.joined(separator: "/")
            + "/"
    }

    // MARK: - asset helpers

    func assetExists(_ id: String) -> Bool {
        assets[id] != nil
    }

    func assetUrl(
        for path: String?,
        folder: String,
        variant: ImageVariant = .light
    ) -> String? {
        guard let path, !path.isEmpty else {
            return nil
        }
        if path.hasPrefix("./") {
            // TODO: handle this better...
            var key: String
            switch variant {
            case .light:
                key = path
            case .dark:
                var items = path.split(separator: ".")
                items.insert("~dark", at: items.count - 1)
                key =
                    "."
                    + items
                    .joined(separator: ".")
                    .replacingOccurrences(
                        of: ".~dark",
                        with: "~dark"
                    )
            }

            key = key.replacingOccurrences(
                of: "./",
                with: "./\(folder)/"
            )

            if let slug = assets[key] {
                return permalink(slug)
            }
            return nil
        }
        return path
    }

    func figureState(
        for path: String?,
        folder: String,
        alt: String? = nil,
        title: String? = nil
    ) -> FigureState? {
        guard
            let url = assetUrl(
                for: path,
                folder: folder
            )
        else {
            return nil
        }
        return .init(
            src: url,
            darkSrc: assetUrl(
                for: path,
                folder: folder,
                variant: .dark
            ),
            alt: alt,
            title: title
        )
    }
}

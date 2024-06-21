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

    let source: Source
    let destinationUrl: URL

    let currentYear: Int
    let dateFormatter: DateFormatter
    let rssDateFormatter: DateFormatter
    let sitemapDateFormatter: DateFormatter

    init(
        source: Source,
        destinationUrl: URL
    ) {
        self.source = source
        self.destinationUrl = destinationUrl

        let calendar = Calendar(identifier: .gregorian)
        self.currentYear = calendar.component(.year, from: .init())

        self.dateFormatter = DateFormatters.baseFormatter
        self.dateFormatter.dateFormat = source.config.site.dateFormat
        self.rssDateFormatter = DateFormatters.rss
        self.sitemapDateFormatter = DateFormatters.sitemap
    }

    // MARK: -

    var baseUrl: String { source.config.site.baseUrl }

    func permalink(_ value: String) -> String {
        let components = value.split(separator: "/").map(String.init)
        if components.isEmpty {
            return baseUrl
        }
        if components.last?.split(separator: ".").count ?? 0 > 1 {
            return baseUrl + components.joined(separator: "/")
        }
        return baseUrl + components.joined(separator: "/") + "/"
    }
    
    func figureState(
        for path: String?,
        folder: String,
        alt: String? = nil,
        title: String? = nil
    ) -> State.Figure? {
        nil
//        source.assets.url(for: <#T##String?#>, folder: <#T##String#>, permalink: <#T##(String) -> String#>)
//        
//        guard
//            let url = source.assets.url(
//                for: path,
//                folder: folder
//            )
//        else {
//            return nil
//        }
//        return .init(
//            src: url,
//            darkSrc: nil,
//            darkSrc: assetUrl(
//                for: path,
//                folder: folder,
//                variant: .dark
//            ),
//            alt: alt,
//            title: title
//        )
    }

    func metadata(
        for content: Source.Content
    ) -> State.Metadata {
        .init(
            slug: content.slug,
            permalink: permalink(content.slug),
            title: content.title,
            description: content.description,
            imageUrl: nil  // TODO: fix this
                //            imageUrl: assetUrl(
                //                for: content.coverImage,
                //                folder: type(of: content).folder
                //            )
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

    func siteState() -> State.Site {
        .init(
            baseUrl: source.config.site.baseUrl,
            title: source.config.site.title,
            description: source.config.site.description,
            language: source.config.site.language
        )
    }
    //
    //    // MARK: - content states
    //
    func authorState(
        for author: Source.Content
    ) -> State.Blog.Author {
        .init(
            permalink: permalink(author.slug),
            title: author.title,
            description: author.description,
            figure: figureState(
                for: author.coverImage,
                folder: author.assetsFolder
            ),
            numberOfPosts: 0,
            //content.blog.post.contentsBy(authorSlug: author.slug).count,
            userDefined: [:],
            //author.userDefined,
            markdown: render(
                markdown: author.markdown,
                folder: author.assetsFolder
            )
        )
    }

    func tagState(
        for tag: Source.Content
    ) -> State.Blog.Tag {
        .init(
            permalink: permalink(tag.slug),
            title: tag.title,
            description: tag.description,
            figure: figureState(
                for: tag.coverImage,
                folder: tag.assetsFolder
            ),
            numberOfPosts: 0, //content.blog.post.contentsBy(tagSlug: tag.slug).count,
            userDefined: [:] //tag.userDefined
        )
    }
    //
    //    func pageState(
    //        for page: Content.Page
    //    ) -> PageState {
    //        .init(
    //            permalink: permalink(page.slug),
    //            title: page.title,
    //            description: page.description,
    //            figure: figureState(
    //                for: page.coverImage,
    //                folder: Content.Page.folder
    //            ),
    //            userDefined: page.userDefined
    //        )
    //    }
    //
    //    func postState(
    //        for post: Content.Post,
    //        authors: [Content.Author],
    //        tags: [Content.Tag]
    //    ) -> PostState {
    //        return .init(
    //            permalink: permalink(post.slug),
    //            title: post.title,
    //            excerpt: post.description,
    //            date: dateFormatter.string(from: post.publication),
    //            figure: figureState(
    //                for: post.coverImage,
    //                folder: Content.Post.folder
    //            ),
    //            tags: tags.map { tagState(for: $0) },
    //            authors: authors.map { authorState(for: $0) },
    //            readingTime: readingTime(post.markdown),
    //            featured: post.featured,
    //            userDefined: post.userDefined
    //        )
    //    }
    //
    //    // MARK: - list states
    //
    func tagListState() -> [State.Blog.Tag] {
        source.contents.blog.alphabeticallySortedTags.map {
            tagState(for: $0)
        }
    }
    
    func authorListState() -> [State.Blog.Author] {
        source.contents.blog.alphabeticallySortedAuthors.map {
            authorState(for: $0)
        }
    }
    //
    //    func postListState() -> [PostState] {
    //        content.blog.post.sortedContents.map {
    //            postState(
    //                for: $0,
    //                authors: content.blog.author.contentsBy(slugs: $0.authorSlugs),
    //                tags: content.blog.tag.contentsBy(slugs: $0.tagSlugs)
    //            )
    //        }
    //    }
    //
    //    func featuredPostListState() -> [PostState] {
    //        content.blog.post.sortedContents
    //            .filter { $0.featured }
    //            .map {
    //                postState(
    //                    for: $0,
    //                    authors: content.blog.author.contentsBy(slugs: $0.authorSlugs),
    //                    tags: content.blog.tag.contentsBy(slugs: $0.tagSlugs)
    //                )
    //            }
    //    }
    //
    //    func postListState(authorSlug: String) -> [PostState] {
    //        content.blog.post.contentsBy(authorSlug: authorSlug)
    //            .map {
    //                postState(
    //                    for: $0,
    //                    authors: content.blog.author.contentsBy(slugs: $0.authorSlugs),
    //                    tags: content.blog.tag.contentsBy(slugs: $0.tagSlugs)
    //                )
    //            }
    //    }
    //
    //    func postListState(tagSlug: String) -> [PostState] {
    //        content.blog.post.contentsBy(tagSlug: tagSlug)
    //            .map {
    //                postState(
    //                    for: $0,
    //                    authors: content.blog.author.contentsBy(slugs: $0.authorSlugs),
    //                    tags: content.blog.tag.contentsBy(slugs: $0.tagSlugs)
    //                )
    //            }
    //    }
    //
    //    // MARK: - system page states
    //
    func home() -> Renderable<Output.HTML<State.Main.Home>> {
        let context = Output.HTML<State.Main.Home>
            .init(
                site: siteState(),
                page: .init(
                    metadata: metadata(for: source.contents.pages.main.home),
                    context: .init(
                        featured: [],
                        posts: [],
                        authors: [],
                        tags: [],
                        pages: []
                    ),
                    content: render(
                        markdown: source.contents.pages.main.home.markdown,
                        folder: source.contents.pages.main.home.assetsFolder
                    )
                ),
                userDefined: [:],
                year: currentYear
            )

        return .init(
            template: source.contents.pages.main.home.template ?? "pages.home",
            context: context,
            destination: destinationUrl.appendingPathComponent(
                "index.html"
            )
        )

    }
    
    func notFound() -> Renderable<Output.HTML<Void>> {
        let page = source.contents.pages.main.notFound
        return .init(
            template: page.template ?? "pages.404",
            context: .init(
                site: siteState(),
                page: .init(
                    metadata: metadata(for: page),
                    context: (),
                    content: render(
                        markdown: page.markdown,
                        folder: page.assetsFolder
                    )
                ),
                userDefined: [:],
                year: currentYear
            ),
            destination: destinationUrl
                .appendingPathComponent("404.html")
        )
        
//        let notFoundPage = content.notFound
//        return .init(
//            site: siteState(for: content.config),
//            page: .init(
//                slug: notFoundPage.slug,
//                metadata: metadata(for: notFoundPage),
//                context: .init(),
//                content: render(
//                    markdown: notFoundPage.markdown,
//                    folder: Content.Page.folder
//                )
//            ),
//            userDefined: content.config.site.userDefined
//                + notFoundPage.userDefined,
//            year: currentYear,
//            template: notFoundPage.template ?? "pages.404"
//        )
    }
    //
    //    // MARK: - blog
    //
    //    func blogPage() -> BlogHTMLPageState {
    //        let blogPage = content.blog.home
    //        return .init(
    //            site: siteState(for: content.config),
    //            page: .init(
    //                slug: blogPage.slug,
    //                metadata: metadata(for: blogPage),
    //                context: .init(
    //                    featured: featuredPostListState(),
    //                    posts: postListState(),
    //                    authors: authorListState(),
    //                    tags: tagListState()
    //                ),
    //                content: render(
    //                    markdown: blogPage.markdown,
    //                    folder: Content.Page.folder
    //                )
    //            ),
    //            userDefined: content.config.site.userDefined + blogPage.userDefined,
    //            year: currentYear,
    //            template: blogPage.template ?? "pages.blog.home"
    //        )
    //    }
    //

    func authorList() -> Renderable<Output.HTML<State.Blog.Author.List>>? {
        guard let authors = source.contents.pages.blog.authors else {
            return nil
        }
        return .init(
            template: authors.template ?? "pages.blog.authors",
            context: .init(
                site: siteState(),
                page: .init(
                    metadata: metadata(for: authors),
                    context: .init(authors: authorListState()),
                    content: render(
                        markdown: authors.markdown,
                        folder: authors.assetsFolder
                    )
                ),
                userDefined: [:],
                year: currentYear
            ),
            destination: destinationUrl
                .appendingPathComponent(authors.slug)
                .appendingPathComponent("index.html")
        )
//        return .init(
//            site: siteState(for: content.config),
//            page: .init(
//                slug: authorsPage.slug,
//                metadata: metadata(for: authorsPage),
//                context: .init(
//                    authors: authorListState()
//                ),
//                content: render(
//                    markdown: authorsPage.markdown,
//                    folder: Content.Page.folder
//                )
//            ),
//            userDefined: content.config.site.userDefined
//            + authorsPage.userDefined,
//            year: currentYear,
//            template: authorsPage.template ?? "pages.blog.authors"
//        )
    }
    
    func tagList() -> Renderable<Output.HTML<State.Blog.Tag.List>>? {
        guard let tags = source.contents.pages.blog.tags else {
            return nil
        }
        return .init(
            template: tags.template ?? "pages.blog.tags",
            context: .init(
                site: siteState(),
                page: .init(
                    metadata: metadata(for: tags),
                    context: .init(tags: tagListState()),
                    content: render(
                        markdown: tags.markdown,
                        folder: tags.assetsFolder
                    )
                ),
                userDefined: [:],
                year: currentYear
            ),
            destination: destinationUrl
                .appendingPathComponent(tags.slug)
                .appendingPathComponent("index.html")
        )
        
//        let tagsPage = content.blog.tag.home
//        return .init(
//            site: siteState(for: content.config),
//            page: .init(
//                slug: tagsPage.slug,
//                metadata: metadata(for: tagsPage),
//                context: .init(
//                    tags: tagListState()
//                ),
//                content: render(
//                    markdown: tagsPage.markdown,
//                    folder: Content.Page.folder
//                )
//            ),
//            userDefined: content.config.site.userDefined + tagsPage.userDefined,
//            year: currentYear,
//            template: tagsPage.template ?? "pages.blog.tags"
//        )
    }
    //
    //    func postListPages() -> [PostListHTMLPageState] {
    //        let postsPage = content.blog.post.home
    //        let pageLimit = content.config.blog.posts.page.limit
    //        let pages = content.blog.post.sortedContents.chunks(ofCount: pageLimit)
    //
    //        func replace(
    //            _ number: Int,
    //            _ value: String
    //        ) -> String {
    //            value.replacingOccurrences(
    //                of: "{{number}}",
    //                with: String(number)
    //            )
    //        }
    //
    //        var result: [PostListHTMLPageState] = []
    //        for (index, posts) in pages.enumerated() {
    //            let pageNumber = index + 1
    //
    //            let title = replace(pageNumber, postsPage.title)
    //            let description = replace(pageNumber, postsPage.description)
    //            let slug = replace(pageNumber, postsPage.slug)
    //
    //            let state: PostListHTMLPageState = .init(
    //                site: siteState(
    //                    for: content.config
    //                ),
    //                page: .init(
    //                    slug: slug,
    //                    metadata: .init(
    //                        permalink: permalink(slug),
    //                        title: title,
    //                        description: description,
    //                        imageUrl: assetUrl(
    //                            for: postsPage.coverImage,
    //                            folder: Content.Page.folder
    //                        )
    //                    ),
    //                    context: .init(
    //                        posts: posts.map {
    //                            postState(
    //                                for: $0,
    //                                authors: content.blog.author.contentsBy(
    //                                    slugs: $0.authorSlugs
    //                                ),
    //                                tags: content.blog.tag.contentsBy(
    //                                    slugs: $0.tagSlugs
    //                                )
    //                            )
    //                        },
    //                        pagination: (1...pages.count)
    //                            .map {
    //                                .init(
    //                                    number: $0,
    //                                    total: pages.count,
    //                                    slug: replace($0, postsPage.slug),
    //                                    permalink: permalink(
    //                                        replace($0, postsPage.slug)
    //                                    ),
    //                                    isCurrent: pageNumber == $0
    //                                )
    //                            }
    //                    ),
    //                    content: render(
    //                        markdown: postsPage.markdown,
    //                        folder: Content.Page.folder
    //                    )
    //                ),
    //                userDefined: content.config.site.userDefined
    //                    + postsPage.userDefined,
    //                year: currentYear,
    //                template: postsPage.template ?? "pages.blog.posts"
    //            )
    //
    //            result.append(state)
    //        }
    //
    //        return result
    //    }
    //
    //    // MARK: - detail page states
    //
    //    func authorDetails() -> [AuthorDetailHTMLPageState] {
    //        content.blog.author.contents.map {
    //            .init(
    //                site: siteState(for: content.config),
    //                page: .init(
    //                    slug: $0.slug,
    //                    metadata: metadata(for: $0),
    //                    context: .init(
    //                        author: authorState(for: $0),
    //                        posts: postListState(authorSlug: $0.slug)
    //                    ),
    //                    content: render(
    //                        markdown: $0.markdown,
    //                        folder: Content.Author.folder
    //                    )
    //                ),
    //                userDefined: content.config.site.userDefined + $0.userDefined,
    //                year: currentYear,
    //                template: $0.template ?? "pages.single.author"
    //            )
    //        }
    //    }
    //
    //    func tagDetails() -> [TagDetailHTMLPageState] {
    //        content.blog.tag.contents.map {
    //            .init(
    //                site: siteState(for: content.config),
    //                page: .init(
    //                    slug: $0.slug,
    //                    metadata: metadata(for: $0),
    //                    context: .init(
    //                        tag: tagState(for: $0),
    //                        posts: postListState(tagSlug: $0.slug)
    //                    ),
    //                    content: render(
    //                        markdown: $0.markdown,
    //                        folder: Content.Tag.folder
    //                    )
    //                ),
    //                userDefined: content.config.site.userDefined + $0.userDefined,
    //                year: currentYear,
    //                template: $0.template ?? "pages.single.tag"
    //            )
    //        }
    //    }
    //
    //    func nextPost(for slug: String) -> PostState? {
    //        let posts = content.blog.post.sortedContents
    //
    //        if let index = posts.firstIndex(where: { $0.slug == slug }) {
    //            if index > 0 {
    //                let post = posts[index - 1]
    //                return postState(
    //                    for: post,
    //                    authors: content.blog.author.contentsBy(
    //                        slugs: post.authorSlugs
    //                    ),
    //                    tags: content.blog.tag.contentsBy(
    //                        slugs: post.tagSlugs
    //                    )
    //                )
    //            }
    //        }
    //        return nil
    //    }
    //
    //    func prevPost(for slug: String) -> PostState? {
    //        let posts = content.blog.post.sortedContents
    //
    //        if let index = posts.firstIndex(where: { $0.slug == slug }) {
    //            if index < posts.count - 1 {
    //                let post = posts[index + 1]
    //                return postState(
    //                    for: post,
    //                    authors: content.blog.author.contentsBy(
    //                        slugs: post.authorSlugs
    //                    ),
    //                    tags: content.blog.tag.contentsBy(
    //                        slugs: post.tagSlugs
    //                    )
    //                )
    //            }
    //        }
    //        return nil
    //    }
    //
    //    func relatedPosts(for slug: String) -> [PostState] {
    //        var result: [PostState] = []
    //
    //        let posts = content.blog.post.sortedContents
    //        if let index = posts.firstIndex(where: { $0.slug == slug }) {
    //            let post = posts[index]
    //            for tagSlug in post.tagSlugs {
    //                result += content.blog.post.contentsBy(tagSlug: tagSlug)
    //                    .filter { $0.slug != slug }
    //                    .map {
    //                        postState(
    //                            for: $0,
    //                            authors: content.blog.author.contentsBy(
    //                                slugs: $0.authorSlugs
    //                            ),
    //                            tags: content.blog.tag.contentsBy(
    //                                slugs: $0.tagSlugs
    //                            )
    //                        )
    //                    }
    //            }
    //        }
    //        return Array(result.shuffled().prefix(5))
    //    }
    //
    //    func moreByPosts(for slug: String) -> [PostState] {
    //        var result: [PostState] = []
    //
    //        let posts = content.blog.post.sortedContents
    //        if let index = posts.firstIndex(where: { $0.slug == slug }) {
    //            let post = posts[index]
    //            for authorSlug in post.authorSlugs {
    //                result += content.blog.post.contentsBy(authorSlug: authorSlug)
    //                    .filter { $0.slug != slug }
    //                    .map {
    //                        postState(
    //                            for: $0,
    //                            authors: content.blog.author.contentsBy(
    //                                slugs: $0.authorSlugs
    //                            ),
    //                            tags: content.blog.tag.contentsBy(
    //                                slugs: $0.tagSlugs
    //                            )
    //                        )
    //                    }
    //            }
    //        }
    //        return Array(result.shuffled().prefix(5))
    //    }
    //
    //    func postDetails() -> [PostDetailHTMLPageState] {
    //        content.blog.post.contents.map {
    //            .init(
    //                site: siteState(for: content.config),
    //                page: .init(
    //                    slug: $0.slug,
    //                    metadata: metadata(for: $0),
    //                    context: .init(
    //                        post: postState(
    //                            for: $0,
    //                            authors: content.blog.author.contentsBy(
    //                                slugs: $0.authorSlugs
    //                            ),
    //                            tags: content.blog.tag.contentsBy(
    //                                slugs: $0.tagSlugs
    //                            )
    //                        ),
    //                        related: relatedPosts(for: $0.slug),
    //                        moreByAuthor: moreByPosts(for: $0.slug),
    //                        next: nextPost(for: $0.slug),
    //                        prev: prevPost(for: $0.slug)
    //                    ),
    //                    content: render(
    //                        markdown: $0.markdown,
    //                        folder: Content.Post.folder
    //                    )
    //                ),
    //                userDefined: content.config.site.userDefined + $0.userDefined,
    //                year: currentYear,
    //                template: $0.template ?? "pages.single.post"
    //            )
    //        }
    //    }
    //
    //    func pages() -> [PageDetailHTMLPageState] {
    //        content.custom.pages.map {
    //            .init(
    //                site: siteState(for: content.config),
    //                page: .init(
    //                    slug: $0.slug,
    //                    metadata: metadata(for: $0),
    //                    context: .init(
    //                        permalink: permalink($0.slug),
    //                        title: $0.title,
    //                        description: $0.description,
    //                        figure: figureState(
    //                            for: $0.coverImage,
    //                            folder: Content.Page.folder
    //                        ),
    //                        userDefined: $0.userDefined
    //                    ),
    //                    content: render(
    //                        markdown: $0.markdown,
    //                        folder: Content.Page.folder
    //                    )
    //                ),
    //                userDefined: content.config.site.userDefined + $0.userDefined,
    //                year: currentYear,
    //                template: $0.template ?? "pages.single.page"
    //            )
    //        }
    //    }

    // MARK: - rss

    func rss() -> Renderable<Output.RSS> {
        let items: [Output.RSS.Item] = source.contents.blog.posts.map {
            .init(
                permalink: permalink($0.slug),
                title: $0.title,
                description: $0.description,
                publicationDate: rssDateFormatter.string(
                    from: .init()
                )
            )
        }

        let publicationDate =
            items.first?.publicationDate
            ?? rssDateFormatter.string(from: .init())

        let context = Output.RSS(
            title: source.config.site.title,
            description: source.config.site.description,
            baseUrl: source.config.site.baseUrl,
            language: source.config.site.language,
            lastBuildDate: rssDateFormatter.string(from: .init()),
            publicationDate: publicationDate,
            items: items
        )

        return .init(
            template: "rss",
            context: context,
            destination: destinationUrl.appendingPathComponent(
                "rss.xml"
            )
        )
    }

    // MARK: - sitemap

    func sitemap() -> Renderable<Output.Sitemap> {
        let context = Output.Sitemap(
            urls: source.contents.all()
                .map { content in
                    .init(
                        location: permalink(content.slug),
                        lastModification: sitemapDateFormatter.string(
                            from: content.lastModification
                        )
                    )
                }
        )
        return .init(
            template: "sitemap",
            context: context,
            destination: destinationUrl.appendingPathComponent(
                "sitemap.xml"
            )
        )
    }
    //
    //    // MARK: - build entire site state
    //
    func buildState() -> Renderables {
        fatalError()
        //        .init(
        //            main: .init(
        //                home: .init(
        //                    template: "",
        //                    context: .init(
        //                        site: .init(
        //                            baseUrl: "",
        //                            title: "",
        //                            description: "",
        //                            language: nil
        //                        ),
        //                        page: .init(
        //                            metadata: .init(
        //                                slug: "",
        //                                permalink: "",
        //                                title: "",
        //                                description: "",
        //                                imageUrl: nil
        //                            ),
        //                            context: .init(featured: [], posts: [], authors: [], tags: [], pages: []),
        //                            content: ""
        //                        ),
        //                        userDefined: [:],
        //                        year: 2024
        //                    ),
        //                    destination: .init(fileURLWithPath: "")
        //                ),
        //                notFound: .init(template: <#T##String#>, context: <#T##State.HTML<Void>#>, destination: <#T##URL#>),
        //                rss: <#T##State.Renderable<State.RSS>#>,
        //                sitemap: <#T##State.Renderable<State.Sitemap>#>
        //            ),
        //            blog: <#T##State.Blog#>,
        //            docs: <#T##State.Docs#>,
        //            pages: []
        //        )
    }
   
}

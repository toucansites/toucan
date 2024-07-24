//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/06/2024.
//

import Foundation
import Logging

/// Responsible to build renderable files using the site context & templates.
struct SiteRenderer {

    public enum Files {
        static let index = "index.html"
        static let notFound = "404.html"
        static let rss = "rss.xml"
        static let sitemap = "sitemap.xml"
    }

    let source: Source

    let currentYear: Int
    let dateFormatter: DateFormatter
    let rssDateFormatter: DateFormatter
    let sitemapDateFormatter: DateFormatter

    let templatesUrl: URL
    let overridesUrl: URL
    let destinationUrl: URL

    let fileManager: FileManager = .default
    let logger: Logger

    let templateRenderer: MustacheToHTMLRenderer

    init(
        source: Source,
        templatesUrl: URL,
        overridesUrl: URL,
        destinationUrl: URL
    ) throws {
        self.source = source
        self.templatesUrl = templatesUrl
        self.overridesUrl = overridesUrl
        self.destinationUrl = destinationUrl

        let calendar = Calendar(identifier: .gregorian)
        self.currentYear = calendar.component(.year, from: .init())

        self.dateFormatter = DateFormatters.baseFormatter
        self.dateFormatter.dateFormat = source.config.site.dateFormat
        self.rssDateFormatter = DateFormatters.rss
        self.sitemapDateFormatter = DateFormatters.sitemap

        self.logger = {
            var logger = Logger(label: "SiteRenderer")
            logger.logLevel = .debug
            return logger
        }()

        self.templateRenderer = try MustacheToHTMLRenderer(
            templatesUrl: templatesUrl,
            overridesUrl: overridesUrl
        )
    }

    // MARK: - context related

    func readingTime(_ value: String) -> Int {
        value.split(separator: " ").count / 238
    }

    func relations(
        for pageBundle: PageBundle
    ) -> [String: [PageBundle]] {
        let contentType = source.contentType(for: pageBundle)
        var relations: [String: [PageBundle]] = [:]
        for (key, value) in contentType.relations ?? [:] {
            let refIds = pageBundle.referenceIdentifiers(
                for: key,
                join: value.join
            )

            let refs =
                source
                .pageBundles(by: value.references)
                /// filter down based on the condition
                .filter { item in
                    refIds.contains(item.contextAwareIdentifier)
                }
                .sorted(key: value.sort, order: value.order)
                .limited(value.limit)

            relations[key] = refs
        }
        return relations
    }

    func globalContext() -> [String: [PageBundle]] {
        var globalContext: [String: [PageBundle]] = [:]
        for contentType in source.contentTypes {
            for (key, value) in contentType.context?.site ?? [:] {
                globalContext[key] =
                    source
                    .pageBundles(by: contentType.id)
                    .sorted(key: value.sort, order: value.order)
                    .filtered(value.filter)
                    // TODO: proper pagination
                    .limited(value.limit)
            }
        }
        return globalContext
    }

    func localContext(
        for pageBundle: PageBundle
    ) -> [String: [PageBundle]] {
        let id = pageBundle.contextAwareIdentifier
        var localContext: [String: [PageBundle]] = [:]
        let contentType = source.contentType(for: pageBundle)

        for (key, value) in contentType.context?.local ?? [:] {
            if value.foreignKey.hasPrefix("$") {
                var command = String(value.foreignKey.dropFirst())
                var arguments: [String] = []
                if command.contains(".") {
                    let all = command.split(separator: ".")
                    command = String(all[0])
                    arguments = all.dropFirst().map(String.init)
                }

                let refs =
                    source
                    .pageBundles(by: value.references)
                    .sorted(key: value.sort, order: value.order)

                guard
                    let idx = refs.firstIndex(where: {
                        $0.context.slug == pageBundle.context.slug
                    })
                else {
                    continue
                }

                switch command {
                case "prev":
                    guard idx > 0 else {
                        continue
                    }
                    localContext[key] = [refs[idx - 1]]
                case "next":
                    guard idx < refs.count - 1 else {
                        continue
                    }
                    localContext[key] = [refs[idx + 1]]
                case "same":
                    guard let arg = arguments.first else {
                        continue
                    }
                    let ids = Set(pageBundle.referenceIdentifiers(for: arg))
                    localContext[key] =
                        refs.filter { pb in
                            if pb.context.slug == pageBundle.context.slug {
                                return false
                            }
                            let pbIds = Set(pb.referenceIdentifiers(for: arg))
                            return !ids.intersection(pbIds).isEmpty
                        }
                        .limited(value.limit)
                default:
                    continue
                }
            }
            else {
                localContext[key] =
                    source
                    .pageBundles(by: value.references)
                    .filter {
                        $0.referenceIdentifiers(
                            for: value.foreignKey
                        )
                        .contains(id)
                    }
                    .sorted(key: value.sort, order: value.order)
                    .limited(value.limit)
            }
        }
        return localContext
    }

    func contentContext(
        for pageBundle: PageBundle
    ) -> [String: Any] {
        let renderer = MarkdownRenderer(
            delegate: HTMLRendererDelegate(
                config: source.config,
                pageBundle: pageBundle
            )
        )
        var context: [String: Any] = [:]
        context["readingTime"] = readingTime(pageBundle.markdown)
        context["toc"] = renderer.renderToC(markdown: pageBundle.markdown)
        context["contents"] = renderer.renderHTML(markdown: pageBundle.markdown)
        return context
    }

    func getContext(
        pageBundle: PageBundle
    ) -> [String: Any] {
        logger.trace("slug: \(pageBundle.context.slug)")
        logger.trace("type: \(pageBundle.type)")

        let relations = relations(for: pageBundle)

        logger.trace("relations:")
        for (key, values) in relations {
            logger.trace("\t\(key):")
            for item in values {
                logger.trace("\t - \(item.context.slug)")
            }
        }

        let localContext = localContext(for: pageBundle)
        logger.trace("local context:")
        for (key, values) in localContext {
            logger.trace("\t\(key):")
            for item in values {
                logger.trace("\t - \(item.context.slug)")
            }
        }

        //        if pageBundle.context.slug.contains("blog/authors/albert-einstein") {
        //            print("---")
        //            print(relations)
        //            print(localContext.keys)
        //        }

        return pageBundle.context.dict
            .recursivelyMerged(
                with: relations.mapValues { $0.map(\.context.dict) }
            )
            .recursivelyMerged(
                with: localContext.mapValues {
                    $0.map(\.context.dict)
                }
            )
            .recursivelyMerged(with: contentContext(for: pageBundle))
    }

    // MARK: - page bundle rendering

    func renderHTML(
        pageBundle: PageBundle,
        globalContext: [String: [PageBundle]]
    ) throws {

        var fileUrl =
            destinationUrl
            .appendingPathComponent(pageBundle.context.slug)
            .appendingPathComponent(Files.index)

        if pageBundle.context.slug == "404" {
            fileUrl =
                destinationUrl
                .appendingPathComponent(Files.notFound)
        }

        if let output = pageBundle.output {
            fileUrl =
                destinationUrl
                .appendingPathComponent(output)
        }

        try fileManager.createParentFolderIfNeeded(
            for: fileUrl
        )

        try templateRenderer.render(
            template: pageBundle.template,
            with: HTML(
                site: .init(
                    baseUrl: source.config.site.baseUrl,
                    title: source.config.site.title,
                    description: source.config.site.description,
                    language: source.config.site.language,
                    context: globalContext.mapValues {
                        $0.map { getContext(pageBundle: $0) }
                    }
                ),
                page: getContext(pageBundle: pageBundle),
                userDefined: pageBundle.userDefined, // TODO: merge with site
                data: pageBundle.data,
                year: currentYear
            ),
            to: fileUrl
        )

    }

    // MARK: - render related methods

    func render() throws {
        let globalContext = globalContext()

        logger.trace("global context:")
        for (key, values) in globalContext {
            logger.trace("\t\(key):")
            for item in values {
                logger.trace("\t - \(item.context.slug)")
            }
        }

        for pageBundle in source.pageBundles {
            try renderHTML(
                pageBundle: pageBundle,
                globalContext: globalContext
            )
        }

        try renderRSS()
        try renderSitemap()
        try renderRedirects()
    }

    func renderRSS() throws {
        let items: [RSS.Item] = source.rssPageBundles()
            .map { item in
                .init(
                    permalink: item.context.permalink,
                    title: item.context.title,
                    description: item.context.description,
                    publicationDate: rssDateFormatter.string(
                        from: item.publication
                    )
                )
            }

        let publicationDate =
            items.first?.publicationDate
            ?? rssDateFormatter.string(from: .init())

        let context = RSS(
            title: source.config.site.title,
            description: source.config.site.description,
            baseUrl: source.config.site.baseUrl,
            language: source.config.site.language,
            lastBuildDate: rssDateFormatter.string(from: .init()),
            publicationDate: publicationDate,
            items: items
        )

        try templateRenderer.render(
            template: "rss",
            with: context,
            to: destinationUrl.appendingPathComponent(Files.rss)
        )
    }

    func renderSitemap() throws {
        let context = Sitemap(
            urls: source.pageBundles
                .sorted { $0.publication > $1.publication }
                .map {
                    .init(
                        location: $0.context.permalink,
                        lastModification: sitemapDateFormatter.string(
                            from: $0.lastModification
                        )
                    )
                }
        )
        try templateRenderer.render(
            template: "sitemap",
            with: context,
            to: destinationUrl.appendingPathComponent(Files.sitemap)
        )
    }

    func renderRedirects() throws {
        for pageBundle in source.pageBundles {
            for redirect in pageBundle.redirects {

                let fileUrl =
                    destinationUrl
                    .appendingPathComponent(redirect.from)
                    .appendingPathComponent(Files.index)

                try fileManager.createParentFolderIfNeeded(
                    for: fileUrl
                )

                try templateRenderer.render(
                    template: "redirect",
                    with: Redirect(
                        url: pageBundle.context.permalink,
                        code: redirect.code.rawValue
                    ),
                    to: fileUrl
                )
            }
        }
    }
}

// NOTE: this is a complete hack for now...
extension [PageBundle] {

    func sorted(
        key: String?,
        order: ContentType.Order?
    ) -> [PageBundle] {
        guard let key, let order else {
            return self
        }
        return sorted { lhs, rhs in
            guard
                let l = lhs.frontMatter[key] as? String,
                let r = rhs.frontMatter[key] as? String
            else {
                guard
                    let l = lhs.frontMatter[key] as? Int,
                    let r = rhs.frontMatter[key] as? Int
                else {
                    return false
                }
                switch order {
                case .asc:
                    return l < r
                case .desc:
                    return l > r
                }
            }
            // TODO: proper case insensitive compare
            switch order {
            case .asc:
                return l.lowercased() < r.lowercased()
            case .desc:
                return l.lowercased() > r.lowercased()
            }
        }
    }

    func limited(_ value: Int?) -> [PageBundle] {
        Array(prefix(value ?? Int.max))
    }

    func filtered(_ filter: ContentType.Filter?) -> [PageBundle] {
        guard let filter else {
            return self
        }
        return self.filter { pageBundle in
            guard let field = pageBundle.frontMatter[filter.field] else {
                return false
            }
            switch filter.method {
            case .equals:
                // this is horrible... 😱
                return String(describing: field) == filter.value
            }
        }
    }
}

// TODO: pagination
// MARK: - post

//    func replacePaginationInfo(
//        current: Int,
//        total: Int,
//        in value: String
//    ) -> String {
//        value.replacingOccurrences(
//            of: "{{pages.current}}",
//            with: String(current)
//        )
//        .replacingOccurrences(
//            of: "{{pages.total}}",
//            with: String(total)
//        )
//    }

//    func blogPostListPaginated(
//    ) -> [Renderable<HTML<Context.Blog.Post.ListPage>>] {
//        guard let posts = site.source.materials.pages.blog.posts else {
//            return []
//        }
//
//        let pageLimit = Int(site.source.config.contents.pagination.limit)
//        let pages = site.contents.blog.posts.chunks(ofCount: pageLimit)
//
//        var result: [Renderable<HTML<Context.Blog.Post.ListPage>>] = []
//        for (index, postsChunk) in pages.enumerated() {
//            let pageNumber = index + 1
//
//
//
//            let title = replacePaginationInfo(
//                current: pageNumber,
//                total: pages.count,
//                in: posts.title
//            )
//            let description = replacePaginationInfo(
//                current: pageNumber,
//                total: pages.count,
//                in: posts.description
//            )
//            let slug = replacePaginationInfo(
//                current: pageNumber,
//                total: pages.count,
//                in: posts.slug
//            )
//
//            var prev: String? = nil
//            if index > 0 {
//                prev = replacePaginationInfo(
//                    current: pageNumber - 1,
//                    total: pages.count,
//                    in: posts.slug
//                )
//            }
//
//            var next: String? = nil
//            if index < pages.count - 1 {
//                next = replacePaginationInfo(
//                    current: pageNumber - 1,
//                    total: pages.count,
//                    in: posts.slug
//                )
//            }
//
//            let material = posts.updated(
//                title: title,
//                description: description,
//                markdown: replacePaginationInfo(
//                    current: pageNumber,
//                    total: pages.count,
//                    in: posts.markdown
//                ),
//                slug: slug
//            )
//            let context = site.getOutputHTMLContext(
//                material: material,
//                context: Context.Blog.Post.ListPage(
//                    posts: postsChunk.map { $0.context(site: site) },
//                    pagination: (1...pages.count)
//                        .map {
//                            let slug = replacePaginationInfo(
//                                current: $0,
//                                total: pages.count,
//                                in: posts.slug
//                            )
//                            return .init(
//                                number: $0,
//                                total: pages.count,
//                                slug: slug,
//                                permalink: site.permalink(slug),
//                                isCurrent: pageNumber == $0
//                            )
//                        }
//                ),
//                prev: prev.map { site.permalink($0) },
//                next: next.map { site.permalink($0) }
//            )
//
//            let r = Renderable<HTML<Context.Blog.Post.ListPage>>(
//                template: material.template,
//                context: context,
//                destination: destinationUrl
//                    .appendingPathComponent(slug)
//                    .appendingPathComponent(Files.index)
//            )
//
//            result.append(r)
//        }
//        return result
//    }

// TODO: this is tricky, next / prev over refs, using a generic approach...
//func prev(_ guide: Guide) -> Guide? {
//            let guides = guides(category: guide.category)
//            guard
//                let index = guideIndex(for: guide, in: guides),
//                index > 0
//            else {
//                if
//                    let categoryIndex = categoryIndex(for: guide.category),
//                    categoryIndex > 0
//                {
//                    let nextIndex = categoryIndex - 1
//                    let category = categories[nextIndex]
//                    return self.guides(category: category).last
//                }
//                return nil
//            }
//            return guides[index - 1]
//        }
//
//        func next(_ guide: Guide) -> Guide? {
//            let guides = guides(category: guide.category)
//            guard
//                let index = guideIndex(for: guide, in: guides),
//                index < guides.count - 1
//            else {
//                if
//                    let categoryIndex = categoryIndex(for: guide.category),
//                    categoryIndex < categories.count - 1
//                {
//                    let nextIndex = categoryIndex + 1
//                    let category = categories[nextIndex]
//                    return self.guides(category: category).first
//                }
//                return nil
//            }
//            return guides[index + 1]
//        }

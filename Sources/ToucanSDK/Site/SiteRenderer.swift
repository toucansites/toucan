//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/06/2024.
//

import Foundation
import Logging
import Dispatch
import ShellKit
import Algorithms
import SwiftSoup

// TODO: use actor & modern concurrency
final class Cache {

    let q = DispatchQueue(
        label: "com.binarybirds.toucan.cache",
        attributes: .concurrent
    )

    var storage: [String: Any]

    init() {
        self.storage = [:]
    }

    func set(key: String, value: Any) {
        q.async(flags: .barrier) {
            self.storage[key] = value
        }

    }

    func get(key: String) -> Any? {
        q.sync {
            self.storage[key]
        }
    }
}

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

    var cache: Cache

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

        self.cache = .init()
    }

    // MARK: - context related

    func readingTime(_ value: String) -> Int {
        value.split(separator: " ").count / 238
    }

    func relations(
        for pageBundle: PageBundle
    ) -> [String: [PageBundle]] {
        let contentType = source.contentType(for: pageBundle)
        var result: [String: [PageBundle]] = [:]
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

            result[key] = refs
        }
        return result
    }

    func globalContext() -> [String: [PageBundle]] {
        var result: [String: [PageBundle]] = [:]
        for contentType in source.contentTypes {
            for (key, value) in contentType.context?.site ?? [:] {
                let pageBundles = source.pageBundles(by: contentType.id)
                    .sorted(key: value.sort, order: value.order)
                result[key] =
                    pageBundles
                    .filtered(value.filter)
                    // TODO: proper pagination
                    .limited(value.limit)
            }
        }
        return result
    }

    // TODO: optimize & merge with data?
    func paginationContext(
        for pageBundle: PageBundle
    ) -> [String: [Context.Pagination.Link]] {
        var result: [String: [Context.Pagination.Link]] = [:]
        for contentType in source.contentTypes {
            guard let pagination = contentType.pagination else { continue }
            let paginationBundle = source.pageBundles.first { pageBundle in
                guard pageBundle.type == ContentType.pagination.id else {
                    return false
                }
                guard pageBundle.id == pagination.bundle else { return false }
                guard pageBundle.context.slug.contains("{{number}}") else {
                    return false
                }
                return true
            }
            guard let paginationBundle else {
                continue
            }

            let pageBundles = source.pageBundles(by: contentType.id)
                .sorted(key: pagination.sort, order: pagination.order)

            let limit = pagination.limit
            let pages = pageBundles.chunks(ofCount: limit)
            let total = pages.count

            var ctx: [Context.Pagination.Link] = []
            for (index, _) in pages.enumerated() {
                let number = index + 1
                let slug = paginationBundle.context.slug.replacingOccurrences([
                    "{{number}}": String(number),
                    "{{total}}": String(total),
                ])
                let permalink = slug.permalink(
                    baseUrl: source.config.site.baseUrl
                )
                let isCurrent = pageBundle.context.slug == slug
                ctx.append(
                    .init(
                        number: number,
                        total: total,
                        slug: slug,
                        permalink: permalink,
                        isCurrent: isCurrent
                    )
                )
            }
            result[contentType.id] = ctx
        }
        return result
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

        // TODO: check if transformer exists
        let transformersUrl = source.url.appendingPathComponent("transformers")
        let availableTransformers =
            fileManager
            .listDirectory(at: transformersUrl)
            .filter { !$0.hasPrefix(".") }
            .sorted()

        let contentType = source.contentType(for: pageBundle)
        let run = contentType.transformers?.run ?? []
        let renderFallback = contentType.transformers?.render ?? true

        //        let transformers = pageBundle.frontMatter.dict("transformers")
        //        let renderFallback = transformers.bool("render")
        //        let run = transformers.array("run", as: [String: Any].self)

        let markdown = pageBundle.markdown.dropFrontMatter()
        var toc: [ToC]? = nil
        var time: Int? = nil
        var contents = ""

        // TODO: better transformers settings merge with page bundle
        if !run.isEmpty {
            let shell = Shell(env: ProcessInfo.processInfo.environment)

            // Create a temporary directory URL
            let tempDirectoryURL = FileManager.default.temporaryDirectory
            let fileName = UUID().uuidString
            let fileURL = tempDirectoryURL.appendingPathComponent(fileName)
            try! markdown.write(to: fileURL, atomically: true, encoding: .utf8)

            for r in run {
                guard availableTransformers.contains(r.name) else {
                    continue
                }
                var rawOptions = r.options ?? [:]
                rawOptions["file"] = fileURL.path
                // TODO: this is not necessary the right way...
                rawOptions["id"] = pageBundle.contextAwareIdentifier
                rawOptions["slug"] = pageBundle.context.slug

                let bin = transformersUrl.appendingPathComponent(r.name).path
                let options =
                    rawOptions
                    .map { #"--\#($0) "\#($1)""# }
                    .joined(separator: " ")

                do {
                    let cmd = #"\#(bin) \#(options)"#
                    //                    print(cmd)
                    let log = try shell.run(cmd)
                    if !log.isEmpty {
                        print(log)
                    }
                }
                catch {
                    print("\(error)")
                }
            }
            contents = try! String(contentsOf: fileURL, encoding: .utf8)
            try? fileManager.delete(at: fileURL)

            time = readingTime(contents)

            do {
                let doc: Document = try SwiftSoup.parse(contents)

                var tocList: [MarkupToHXVisitor.HX] = []
                let headings = try doc.select("h2, h3")
                for h in headings {
                    let n = h.nodeName()
                    let attr = try h.attr("id")
                    guard !attr.isEmpty else { continue }
                    let val = try h.text()

                    let level = n.hasSuffix("2") ? 2 : 3

                    tocList.append(
                        .init(
                            level: level,
                            text: val,
                            fragment: attr
                        )
                    )
                }

                toc = MarkdownRenderer.buildToC(tocList)

            }
            catch Exception.Error(_, let message) {
                print(message)
            }
            catch {
                print("error")
            }
        }

        if renderFallback {
            contents = renderer.renderHTML(markdown: markdown)
        }

        var context: [String: Any] = [:]
        context["readingTime"] = time ?? readingTime(markdown)
        context["toc"] = toc ?? renderer.renderToC(markdown: markdown)
        context["contents"] = contents

        return context
    }

    func getContext(
        pageBundle: PageBundle
    ) -> [String: Any] {

        if let res = cache.get(key: pageBundle.context.slug) as? [String: Any] {
            return res
        }

        logger.trace("slug: \(pageBundle.context.slug)")
        logger.trace("type: \(pageBundle.type)")

        let contentType = source.contentType(for: pageBundle)

        var properties: [String: Any] = [:]
        for (key, _) in contentType.properties ?? [:] {
            let value = pageBundle.frontMatter[key]
            properties[key] = value
        }

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

        let res = pageBundle.context.dict
            .recursivelyMerged(
                with: properties
            )
            .recursivelyMerged(
                with: relations.mapValues { $0.map(\.context.dict) }
            )
            .recursivelyMerged(
                with: localContext.mapValues {
                    $0.map(\.context.dict)
                }
            )
            .recursivelyMerged(with: contentContext(for: pageBundle))

        cache.set(key: pageBundle.context.slug, value: res)

        return res
    }

    // MARK: - page bundle rendering

    func renderHTML(
        pageBundle: PageBundle,
        globalContext: [String: [PageBundle]],
        paginationContext: [String: [Context.Pagination.Link]],
        paginationData: [String: [PageBundle]]
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
                userDefined: pageBundle.userDefined,
                // TODO: merge with site
                data: pageBundle.data,
                pagination: .init(
                    links: paginationContext,
                    data: paginationData.mapValues {
                        $0.map { getContext(pageBundle: $0) }
                    }
                ),
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
            guard pageBundle.type != ContentType.pagination.id else {
                continue
            }
            try renderHTML(
                pageBundle: pageBundle,
                globalContext: globalContext,
                paginationContext: paginationContext(for: pageBundle),
                paginationData: [:]
            )
        }

        for contentType in source.contentTypes {
            guard let pagination = contentType.pagination else { continue }

            for pageBundle in source.pageBundles {
                guard pageBundle.type == ContentType.pagination.id else {
                    continue
                }
                guard pageBundle.id == pagination.bundle else { continue }
                guard pageBundle.context.slug.contains("{{number}}") else {
                    continue
                }

                let pageBundles = source.pageBundles(by: contentType.id)
                    .sorted(key: pagination.sort, order: pagination.order)

                let limit = pagination.limit
                let pages = pageBundles.chunks(ofCount: limit)
                let total = pages.count

                func replace(
                    in value: String,
                    number: Int,
                    total: Int
                ) -> String {
                    value.replacingOccurrences([
                        "{{number}}": String(number),
                        "{{total}}": String(total),
                    ])
                }

                if let home = pageBundle.frontMatter["home"] as? String,
                    !home.isEmpty
                {
                    //                    print("---------------------")
                    //                    print(home)
                }

                for (index, current) in pages.enumerated() {
                    let number = index + 1
                    let finalSlug = replace(
                        in: pageBundle.context.slug,
                        number: number,
                        total: total
                    )
                    let finalPermalink = finalSlug.permalink(
                        baseUrl: source.config.site.baseUrl
                    )
                    let finalTitle = replace(
                        in: pageBundle.context.title,
                        number: number,
                        total: total
                    )
                    let finalDescription = replace(
                        in: pageBundle.context.description,
                        number: number,
                        total: total
                    )
                    let finalMarkdown = replace(
                        in: pageBundle.markdown,
                        number: number,
                        total: total
                    )

                    let finalBundle = PageBundle(
                        id: pageBundle.id,
                        url: pageBundle.url,
                        frontMatter: pageBundle.frontMatter,
                        markdown: finalMarkdown,
                        type: pageBundle.type,
                        lastModification: pageBundle.lastModification,
                        publication: pageBundle.publication,
                        expiration: pageBundle.expiration,
                        template: pageBundle.template,
                        output: pageBundle.output,
                        assets: pageBundle.assets,
                        redirects: pageBundle.redirects,
                        userDefined: pageBundle.userDefined,
                        data: pageBundle.data,
                        context: .init(
                            slug: finalSlug,
                            permalink: finalPermalink,
                            title: finalTitle,
                            description: finalDescription,
                            imageUrl: pageBundle.context.imageUrl,
                            lastModification: pageBundle.context
                                .lastModification,
                            publication: pageBundle.context.publication,
                            expiration: pageBundle.context.expiration,
                            noindex: pageBundle.context.noindex,
                            canonical: pageBundle.context.canonical,
                            hreflang: pageBundle.context.hreflang,
                            css: pageBundle.context.css,
                            js: pageBundle.context.js
                        )
                    )

                    try renderHTML(
                        pageBundle: finalBundle,
                        globalContext: globalContext,
                        paginationContext: paginationContext(for: finalBundle),
                        paginationData: [contentType.id: Array(current)]
                    )
                }
            }
        }

        try? renderRSS()
        try? renderSitemap()
        try? renderRedirects()
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
            urls: source.sitemapPageBundles()
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
        switch key {
        case "publication":
            return sorted { lhs, rhs in
                switch order {
                case .asc:
                    return lhs.publication < rhs.publication
                case .desc:
                    return lhs.publication > rhs.publication
                }
            }
        default:
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
//                    switch l.caseInsensitiveCompare(r) {
//                    case .orderedAscending:
//                        return true
//                    case .orderedDescending:
//                        return false
//                    case .orderedSame:
//                        return false
//                    }
                    return l.lowercased() < r.lowercased()
                case .desc:
                    return l.lowercased() > r.lowercased()
                }
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

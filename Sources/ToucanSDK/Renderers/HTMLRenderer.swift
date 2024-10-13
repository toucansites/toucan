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

/// Responsible to build renderable files using the site context & templates.
struct HTMLRenderer {

    public enum Files {
        static let index = "index.html"
        static let notFound = "404.html"
    }

    let source: Source
    let destinationUrl: URL
    let templateRenderer: MustacheToHTMLRenderer
    let logger: Logger

    let fileManager: FileManager = .default
    let currentYear: Int
    var cache: Cache

    init(
        source: Source,
        destinationUrl: URL,
        templateRenderer: MustacheToHTMLRenderer,
        logger: Logger
    ) throws {
        self.source = source
        self.destinationUrl = destinationUrl
        self.templateRenderer = templateRenderer
        self.logger = logger

        let calendar = Calendar(identifier: .gregorian)
        self.currentYear = calendar.component(.year, from: .init())

        self.cache = .init()
    }

    // MARK: - context related

    func readingTime(_ value: String) -> Int {
        max(value.split(separator: " ").count / 238, 1)
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
                guard pageBundle.contentType.id == ContentType.pagination.id
                else {
                    return false
                }
                guard pageBundle.id == pagination.bundle else { return false }
                guard pageBundle.slug.contains("{{number}}") else {
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
                let slug = paginationBundle.slug.replacingOccurrences([
                    "{{number}}": String(number),
                    "{{total}}": String(total),
                ])
                let permalink = slug.permalink(
                    baseUrl: source.sourceConfig.config.site.baseUrl
                )
                let isCurrent = pageBundle.slug == slug
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
                        $0.slug == pageBundle.slug
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
                            if pb.slug == pageBundle.slug {
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
                config: source.sourceConfig.config,
                pageBundle: pageBundle
            )
        )

        // TODO: check if transformer exists
        let transformersUrl = source.sourceConfig.sourceUrl
            .appendingPathComponent("transformers")
        let availableTransformers =
            fileManager
            .listDirectory(at: transformersUrl)
            .filter { !$0.hasPrefix(".") }
            .sorted()

        let contentType = source.contentType(for: pageBundle)

        // TODO: handle multiple pipeline for same content type
        let pipeline = source.sourceConfig.config.transformers.pipelines
            .filter { p in
                p.types.contains(contentType.id)
            }
            .first

        let run = pipeline?.run ?? []
        let renderFallback = pipeline?.render ?? true

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
                guard availableTransformers.contains(r) else {
                    continue
                }
                var rawOptions: [String: String] = [:]
                rawOptions["file"] = fileURL.path
                // TODO: this is not necessary the right way...
                rawOptions["id"] = pageBundle.contextAwareIdentifier
                rawOptions["slug"] = pageBundle.slug

                let bin = transformersUrl.appendingPathComponent(r).path
                let options =
                    rawOptions
                    .map { #"--\#($0) "\#($1)""# }
                    .joined(separator: " ")

                do {
                    let cmd = #"\#(bin) \#(options)"#
                    //                    print(cmd)
                    let log = try shell.run(cmd)
                    if !log.isEmpty {
                        logger.debug("\(log)")
                    }
                }
                catch {
                    logger.error("\(error.localizedDescription)")
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
                logger.error("\(message)")
            }
            catch {
                logger.error("\(error.localizedDescription)")
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

        if let res = cache.get(key: pageBundle.slug) as? [String: Any] {
            return res
        }

        let metadata: Logger.Metadata = [
            "type": "\(pageBundle.contentType.id)",
            "slug": "\(pageBundle.slug)",
        ]

        logger.trace("Generating context", metadata: metadata)

        let contentType = source.contentType(for: pageBundle)

        var properties: [String: Any] = [:]
        for (key, _) in contentType.properties ?? [:] {
            let value = pageBundle.frontMatter[key]
            properties[key] = value
        }

        let relations = relations(for: pageBundle)

        logger.trace("relations:", metadata: metadata)
        for (key, values) in relations {
            logger.trace("\t\(key):")
            for item in values {
                logger.trace("\t - \(item.slug)", metadata: metadata)
            }
        }

        let localContext = localContext(for: pageBundle)
        logger.trace("local context:", metadata: metadata)
        for (key, values) in localContext {
            logger.trace("\t\(key):", metadata: metadata)
            for item in values {
                logger.trace("\t - \(item.slug)", metadata: metadata)
            }
        }

        let res = pageBundle.dict
            .recursivelyMerged(
                with: properties
            )
            .recursivelyMerged(
                with:
                    relations
                    // TODO: fix this, it can lead to a recursive call!!!
                    //                    .mapValues { $0.map { getContext(pageBundle: $0) } }
                    .mapValues { $0.map(\.dict) }
            )
            .recursivelyMerged(
                with: localContext.mapValues {
                    $0.map(\.dict)
                }
            )
            .recursivelyMerged(with: contentContext(for: pageBundle))

        cache.set(key: pageBundle.slug, value: res)

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
            .appendingPathComponent(pageBundle.slug)
            .appendingPathComponent(Files.index)

        if pageBundle.slug == "404" {
            fileUrl =
                destinationUrl
                .appendingPathComponent(Files.notFound)
        }

        if let output = pageBundle.config.output {
            fileUrl =
                destinationUrl
                .appendingPathComponent(output)
        }

        try fileManager.createParentFolderIfNeeded(
            for: fileUrl
        )

        try templateRenderer.render(
            template: pageBundle.config.template ?? "pages.default",
            with: HTML(
                site: .init(
                    baseUrl: source.sourceConfig.config.site.baseUrl,
                    title: source.sourceConfig.config.site.title,
                    description: source.sourceConfig.config.site.description,
                    language: source.sourceConfig.config.site.language,
                    context: globalContext.mapValues {
                        $0.map { getContext(pageBundle: $0) }
                    }
                ),
                page: getContext(pageBundle: pageBundle),
                userDefined: pageBundle.config.userDefined
                    .recursivelyMerged(
                        with: source.sourceConfig.config.site.userDefined
                    )
                    .sanitized(),
                pagination: .init(
                    links: paginationContext,
                    data: paginationData.mapValues {
                        $0.map { getContext(pageBundle: $0) }
                    }
                ),
                year: currentYear
            )
            .context,
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
                logger.trace("\t - \(item.slug)")
            }
        }

        for pageBundle in source.pageBundles {
            guard pageBundle.contentType.id != ContentType.pagination.id else {
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
                guard pageBundle.contentType.id == ContentType.pagination.id
                else {
                    continue
                }
                guard pageBundle.id == pagination.bundle else { continue }
                guard pageBundle.slug.contains("{{number}}") else {
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
                        in: pageBundle.slug,
                        number: number,
                        total: total
                    )
                    let finalTitle = replace(
                        in: pageBundle.title,
                        number: number,
                        total: total
                    )
                    let finalDescription = replace(
                        in: pageBundle.description,
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
                        slug: finalSlug,
                        permalink: finalSlug.permalink(
                            baseUrl: source.sourceConfig.config.site.baseUrl
                        ),
                        title: finalTitle,
                        description: finalDescription,
                        imageUrl: pageBundle.imageUrl,
                        date: pageBundle.date,
                        contentType: pageBundle.contentType,
                        publication: pageBundle.publication,
                        lastModification: pageBundle.lastModification,
                        config: pageBundle.config,
                        frontMatter: pageBundle.frontMatter,
                        properties: pageBundle.properties,
                        relations: pageBundle.relations,
                        markdown: finalMarkdown
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
    }
}

// TODO: better sort algorithm using data types
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

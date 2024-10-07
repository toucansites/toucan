//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation
import FileManagerKit
import Logging
import Yams

extension String {

    func finalAssetUrl(
        in path: String,
        slug: String
    ) -> String {
        let prefix = "./\(path)/"
        guard hasPrefix(prefix) else {
            return self
        }
        let path = String(dropFirst(prefix.count))
        // TODO: not sure if this is the correct way of handling index assets
        if slug.isEmpty {
            return "/" + path
        }
        return "/assets/" + slug + "/" + path
    }
}

struct PageBundleLocation {
    let slug: String
    let path: String
}

public struct PageBundleLoader {

    public enum Keys: String, CaseIterable {
        case draft
        case publication
        case expiration

        case slug
        case type

        case title
        case description
        case image

        case template
        case output
        case assets
        case redirects

        case noindex
        case canonical
        case hreflang
        case css
        case js
    }

    /// An enumeration representing possible errors that can occur while loading the content.
    public enum Error: Swift.Error {
//        case indexFileNotExists
        /// Indicates an error related to a content.
        case pageBundle(Swift.Error)
    }

    let sourceUrl: URL
    /// The configuration for loading contents.
    let config: Config

    let contentTypes: [ContentType]

    /// The file manager used for file operations.
    let fileManager: FileManager
    /// The front matter parser used for parsing markdown files.
    let frontMatterParser: FrontMatterParser

    let logger: Logger
    
    /// The current date.
    let now: Date = .init()

    let indexName = "index"
    let noindexName = "noindex"
    let mdExtensions = ["md", "markdown"]
    let yamlExtensions = ["yaml", "yml"]

    var extensions: [String] {
        mdExtensions + yamlExtensions
    }

    /// helper
    private var contentUrl: URL {
        sourceUrl.appendingPathComponent(config.content.folder)
    }

    /// Loads all the page bundles.
    func load() throws -> [PageBundle] {
        try loadBundleLocations()
            .sorted { $0.path < $1.path }
            .compactMap { try loadPageBundle(at: $0) }
            .sorted { $0.context.slug < $1.context.slug }
    }

    // MARK: - load helpers

    func loadBundleLocations(
        slug: [String] = [],
        path: [String] = []
    ) throws -> [PageBundleLocation] {
        var result: [PageBundleLocation] = []

        let p = path.joined(separator: "/")
        let url = contentUrl.appendingPathComponent(p)

        if containsIndexFile(name: indexName, at: url) {
            result.append(
                .init(
                    slug: slug.joined(separator: "/"),
                    path: p
                )
            )
        }

        let list = fileManager.listDirectory(at: url)
        for item in list {
            var newSlug = slug
            let childUrl = url.appendingPathComponent(item)
            if !containsIndexFile(name: noindexName, at: childUrl) {
                newSlug += [item]
            }
            let newPath = path + [item]
            result += try loadBundleLocations(slug: newSlug, path: newPath)
        }

        return result
    }

    func containsIndexFile(
        name: String,
        at url: URL
    ) -> Bool {
        for ext in extensions {
            let fileUrl = url.appendingPathComponent("\(name).\(ext)")
            if fileManager.fileExists(at: fileUrl) {
                return true
            }
        }
        return false
    }

    func loadLastModificationDate(
        at url: URL
    ) throws -> Date {
        var date: Date?
        for ext in extensions {
            let fileUrl = url.appendingPathComponent("\(indexName).\(ext)")
            guard fileManager.fileExists(at: fileUrl) else {
                continue
            }
            let fileDate = try fileManager.modificationDate(at: fileUrl)
            if date == nil || date! < fileDate {
                date = fileDate
            }
        }
        precondition(date != nil, "Last modification date is nil.")
        return date!
    }

    func loadRawMarkdown(
        at url: URL
    ) throws -> String {
        for ext in mdExtensions {
            let fileUrl = url.appendingPathComponent("\(indexName).\(ext)")
            if fileManager.fileExists(at: fileUrl) {
                return try String(contentsOf: fileUrl, encoding: .utf8)
            }
        }
        return ""
    }

    func loadFrontMatter(
        id: String,
        dirUrl: URL,
        rawMarkdown: String
    ) throws -> [String: Any] {
        /// use front matter from the markdown file
        let frontMatter = try frontMatterParser.parse(markdown: rawMarkdown)

        /// load additional yaml files for meta data overrides
        let overrides: [String: Any] = try Yaml.load(
            at: dirUrl,
            name: id,
            fileManager: fileManager
        )
        return frontMatter.recursivelyMerged(with: overrides)
    }

    func loadData(
        id: String,
        dirUrl: URL
    ) throws -> [[String: Any]] {
        /// load additional data files for data definitions
        try Yaml.load(
            at: dirUrl,
            name: "\(id).data",
            fileManager: fileManager
        )
    }

    func convert(
        date: Date
    ) -> PageBundle.Context.DateValue {
        let html = DateFormatters.baseFormatter
        html.dateFormat = config.site.dateFormat
        let rss = DateFormatters.rss
        let sitemap = DateFormatters.sitemap

        return .init(
            html: html.string(from: date),
            rss: rss.string(from: date),
            sitemap: sitemap.string(from: date)
        )
    }

    // MARK: - fields

    func draft(frontMatter: [String: Any]) -> Bool {
        frontMatter.bool(Keys.draft.rawValue) ?? false
    }

    func publication(frontMatter: [String: Any]) -> Date {
        guard
            let date = frontMatter.date(
                Keys.publication.rawValue,
                format: config.content.dateFormat
            )
        else {
            return now
        }
        return date
    }

    func expiration(frontMatter: [String: Any]) -> Date? {
        frontMatter.date(
            Keys.expiration.rawValue,
            format: config.content.dateFormat
        )
    }

    func slug(frontMatter: [String: Any], fallback: String) -> String {
        (frontMatter.string(Keys.slug.rawValue).emptyToNil ?? fallback)
            .safeSlug(prefix: nil)
    }

    func contentType(frontMatter: [String: Any]) -> String? {
        frontMatter.string(Keys.type.rawValue).emptyToNil
    }

    func title(frontMatter: [String: Any]) -> String {
        frontMatter.string(Keys.title.rawValue).nilToEmpty
    }

    func description(frontMatter: [String: Any]) -> String {
        frontMatter.string(Keys.description.rawValue).nilToEmpty
    }

    func image(frontMatter: [String: Any]) -> String? {
        frontMatter.string(Keys.image.rawValue).emptyToNil
    }

    func template(
        frontMatter: [String: Any],
        contentType: ContentType
    ) -> String {
        frontMatter.string(Keys.template.rawValue).emptyToNil ?? contentType
            .template ?? ContentType.default.template ?? "pages.single.page"
    }

    func output(frontMatter: [String: Any]) -> String? {
        frontMatter.string(Keys.output.rawValue).emptyToNil
    }

    func assets(frontMatter: [String: Any]) -> String {
        frontMatter.string(Keys.assets.rawValue + ".path").emptyToNil
            ?? "assets"
    }

    func noindex(frontMatter: [String: Any]) -> Bool {
        frontMatter.bool(Keys.noindex.rawValue) ?? false
    }

    func canonical(frontMatter: [String: Any]) -> String? {
        frontMatter.string(Keys.canonical.rawValue).emptyToNil
    }

    func hreflang(frontMatter: [String: Any]) -> [PageBundle.Context.Hreflang] {
        frontMatter
            .array(Keys.hreflang.rawValue, as: [String: String].self)
            .compactMap { dict in
                guard
                    let lang = dict["lang"].emptyToNil,
                    let url = dict["url"].emptyToNil
                else {
                    return nil
                }
                return .init(lang: lang, url: url)
            }
    }

    func redirects(frontMatter: [String: Any]) -> [PageBundle.Redirect] {
        frontMatter
            .array(Keys.redirects.rawValue, as: [String: String].self)
            .compactMap { dict -> PageBundle.Redirect? in
                guard let from = dict["from"].emptyToNil else {
                    return nil
                }
                let code =
                    dict["code"]
                    .flatMap { Int($0) }
                    .flatMap { PageBundle.Redirect.Code(rawValue: $0) }
                    ?? .movedPermanently
                return .init(from: from, code: code)
            }
    }

    func css(frontMatter: [String: Any]) -> [String] {
        frontMatter.array(Keys.css.rawValue, as: String.self)
    }

    func js(frontMatter: [String: Any]) -> [String] {
        frontMatter.array(Keys.js.rawValue, as: String.self)
    }

    // MARK: - loading

    func loadPageBundle(
        at location: PageBundleLocation
    ) throws -> PageBundle? {
        let dirUrl = contentUrl.appendingPathComponent(location.path)

        let metadata: Logger.Metadata = [
            "slug": "\(location.slug)"
        ]

        logger.debug("Loading page bundle at: `\(location.path)`", metadata: metadata)
        
        guard fileManager.directoryExists(at: dirUrl) else {
            logger.debug("Page bundle directory does not exists.", metadata: metadata)
            return nil
        }
        do {
            let lastModification = try loadLastModificationDate(at: dirUrl)
            let rawMarkdown = try loadRawMarkdown(at: dirUrl)
            let markdown = rawMarkdown.dropFrontMatter()

            let frontMatter = try loadFrontMatter(
                id: indexName,
                dirUrl: dirUrl,
                rawMarkdown: rawMarkdown
            )

            let data = try loadData(
                id: indexName,
                dirUrl: dirUrl
            )

            /// filter out drafts
            if draft(frontMatter: frontMatter) {
                logger.debug("Page bundle is a draft.", metadata: metadata)
                return nil
            }
            /// filter out unpublished
            let publication = publication(frontMatter: frontMatter)

            if publication > now {
                logger.debug("Page bundle is not published yet.", metadata: metadata)
                return nil
            }
            /// filter out expired
            let expiration = expiration(frontMatter: frontMatter)
            if let expiration, expiration < now {
                logger.debug("Page bundle is already expired.", metadata: metadata)
                return nil
            }

            let slug = slug(frontMatter: frontMatter, fallback: location.slug)

            var assumedType: String?
            for contentType in contentTypes {
                guard
                    let locPrefix = contentType.location, !locPrefix.isEmpty
                else {
                    continue
                }
                if location.path.hasPrefix(locPrefix) {
                    assumedType = contentType.id
                }
            }

            if let explicitType = contentType(frontMatter: frontMatter) {
                assumedType = explicitType
            }

            let type = assumedType ?? ContentType.default.id

            let contentType = contentTypes.first { $0.id == type }
            guard let contentType else {
                logger.error("Invalid content type.", metadata: metadata)
                return nil
            }

            let title = title(frontMatter: frontMatter)
            let description = description(frontMatter: frontMatter)
            let image = image(frontMatter: frontMatter)

            let template = template(
                frontMatter: frontMatter,
                contentType: contentType
            )
            let output = output(frontMatter: frontMatter)

            let assetsPath = assets(frontMatter: frontMatter)
            let assetsUrl = dirUrl.appendingPathComponent(assetsPath)
            let assets = fileManager.recursivelyListDirectory(at: assetsUrl)

            let noindex = noindex(frontMatter: frontMatter)
            let canonical = canonical(frontMatter: frontMatter)
            let hreflang = hreflang(frontMatter: frontMatter)
            let redirects = redirects(frontMatter: frontMatter)

            /// resolve imageUrl for the page bundle
            let assetsPrefix = "./\(assetsPath)/"
            var imageUrl: String? = nil
            if let image,
                image.hasPrefix(assetsPrefix),
                assets.contains(String(image.dropFirst(assetsPrefix.count)))
            {
                imageUrl = image.finalAssetUrl(in: assetsPath, slug: slug)
            }
            else {
                imageUrl = image
            }

            /// inject style.css if exists, resolve js paths for css assets
            var css = css(frontMatter: frontMatter)
            if assets.contains("style.css") {
                css.append("./\(assetsPath)/style.css")
            }
            css = css.map { $0.finalAssetUrl(in: assetsPath, slug: slug) }

            /// inject main.js if exists, resolve js paths for js assets
            var js = js(frontMatter: frontMatter)
            if assets.contains("main.js") {
                js.append("./\(assetsPath)/main.js")
            }
            js = js.map { $0.finalAssetUrl(in: assetsPath, slug: slug) }

            let propertyKeys = contentType.properties?.keys.sorted() ?? []
            let relationKeys = contentType.relations?.keys.sorted() ?? []
            let userDefined = frontMatter.filter { element in
                !Keys.allCases.map(\.rawValue).contains(element.key)
                    && !propertyKeys.contains(element.key)
                    && !relationKeys.contains(element.key)
            }

            let context = PageBundle.Context(
                slug: slug,
                permalink: slug.permalink(baseUrl: config.site.baseUrl),
                title: title,
                description: description,
                imageUrl: imageUrl,
                lastModification: convert(date: lastModification),
                publication: convert(date: publication),
                expiration: expiration.map { convert(date: $0) },
                noindex: noindex,
                canonical: canonical,
                hreflang: hreflang,
                css: css,
                js: js
            )

            logger.debug("Page bundle is loaded.", metadata: metadata)
            
            return .init(
                id: location.path,
                url: dirUrl,
                frontMatter: frontMatter,
                markdown: markdown,
                type: type,
                lastModification: lastModification,
                publication: publication,
                expiration: expiration,
                template: template,
                output: output,
                assets: .init(path: assetsPath),
                redirects: redirects,
                userDefined: userDefined,
                data: data,
                context: context
            )
        }
        catch {
            throw Error.pageBundle(error)
        }
    }
}


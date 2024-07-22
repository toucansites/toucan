//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation
import FileManagerKit

struct PageBundleLoader {

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
    enum Error: Swift.Error {
        case indexFileNotExists
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

    /// The current date.
    let now: Date = .init()

    /// helper
    private var contentUrl: URL {
        sourceUrl.appendingPathComponent(config.content.folder)
    }

    public func load() throws -> [PageBundle] {
        fileManager
            .recursivelyListDirectory(at: contentUrl)
            .filter { $0.hasSuffix("index.md") }
            // TODO: use noindex for slug removal + allow folder grouping
            .filter { !$0.hasSuffix("noindex.md") }
            .compactMap {
                try? loadPageBundle(at: $0)
            }
            .sorted { $0.context.slug < $1.context.slug }
    }

    func loadFrontMatter(
        id: String,
        dirUrl: URL,
        rawMarkdown: String
    ) throws -> [String: Any] {
        var frontMatter = try frontMatterParser.parse(markdown: rawMarkdown)
        // TODO: use url
        for c in [id + ".yaml", id + ".yml"] {
            let url = dirUrl.appendingPathComponent(c)
            guard fileManager.fileExists(at: url) else {
                continue
            }
            let yaml = try String(contentsOf: url, encoding: .utf8)
            let fm = try frontMatterParser.load(yaml: yaml)
            frontMatter = frontMatter.recursivelyMerged(with: fm)
        }

        var data: [[String: Any]] = []
        for d in [id + ".data.yaml", id + ".data.yml"] {
            let url = dirUrl.appendingPathComponent(d)
            guard fileManager.fileExists(at: url) else {
                continue
            }
            let yaml = try String(contentsOf: url, encoding: .utf8)
            let da =
                try frontMatterParser.load(
                    yaml: yaml,
                    as: [[String: Any]].self
                ) ?? []
            data += da
        }
        return frontMatter
    }

    func convert(
        date: Date
    ) -> PageBundle.Context.DateValue {
        let html = DateFormatters.baseFormatter
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
        guard let date = frontMatter.date(Keys.publication.rawValue) else {
            return now
        }
        return date
    }

    func expiration(frontMatter: [String: Any]) -> Date? {
        frontMatter.date(Keys.expiration.rawValue)
    }

    func slug(frontMatter: [String: Any], id: String) -> String {
        (frontMatter.string(Keys.slug.rawValue).emptyToNil ?? id)
            .safeSlug(prefix: nil)
    }

    func type(frontMatter: [String: Any]) -> String {
        frontMatter.string(Keys.type.rawValue).emptyToNil
            ?? ContentType.default.id
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
        at path: String
    ) throws -> PageBundle? {
        let url = contentUrl.appendingPathComponent(path)
        guard fileManager.fileExists(at: url) else {
            return nil
        }

        do {
            let fileName = url.lastPathComponent
            let dirPath = String(url.path.dropLast(fileName.count))
            let dirUrl = URL(fileURLWithPath: dirPath)
            let id = String(path.dropLast(fileName.count + 1))
            let lastModification = try fileManager.modificationDate(at: url)
            let rawMarkdown = try String(contentsOf: url, encoding: .utf8)
            let markdown = rawMarkdown.dropFrontMatter()
            let frontMatter = try loadFrontMatter(
                id: id,
                dirUrl: dirUrl,
                rawMarkdown: rawMarkdown
            )

            /// filter out drafts
            if draft(frontMatter: frontMatter) {
                return nil
            }
            /// filter out unpublished
            let publication = publication(frontMatter: frontMatter)
            if publication > now {
                return nil
            }
            /// filter out expired
            let expiration = expiration(frontMatter: frontMatter)
            if let expiration, expiration < now {
                return nil
            }

            let slug = slug(frontMatter: frontMatter, id: id)
            let type = type(frontMatter: frontMatter)

            let contentType = contentTypes.first { $0.id == type }
            guard let contentType else {
                // TODO: fatal or log invalid content type
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

            //            print("-------------------")
            //            print(assetsUrl.path())
            //            print(assets.joined(separator: "\n"))

            let assetsPrefix = "./\(assetsPath)/"
            /// resolve imageUrl for the page bundle
            var imageUrl: String? = nil
            if let image,
                image.hasPrefix(assetsPrefix),
                assets.contains(String(image.dropFirst(assetsPrefix.count)))
            {
                imageUrl = image.finalAssetUrl(in: assetsPath, slug: slug)
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
                js: js,
                userDefined: userDefined
            )
            return .init(
                url: .init(fileURLWithPath: dirPath),
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
                context: context
            )
        }
        catch {
            throw Error.pageBundle(error)
        }
    }
}

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
        return "/assets/" + slug + "/" + path
    }
}

//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation
import FileManagerKit

struct PageBundleLoader {
    
    /// An enumeration representing possible errors that can occur while loading the content.
    enum Error: Swift.Error {
        case indexFileNotExists
        /// Indicates an error related to a content.
        case pageBundle(Swift.Error)
    }

    let sourceUrl: URL
    /// The configuration for loading contents.
    let config: Config
    /// The file manager used for file operations.
    let fileManager: FileManager
    /// The front matter parser used for parsing markdown files.
    let frontMatterParser: FrontMatterParser

    /// The current date.
    let now: Date = .init()
    
    /// helper
    private var contentUrl: URL {
        sourceUrl.appendingPathComponent(
            config.content.folder
        )
    }
    
    public func load() throws -> [PageBundle] {
        
        let pageBundles = fileManager
            .recursivelyListDirectory(at: contentUrl)
            .filter { $0.hasSuffix("index.md") }
            .compactMap {
                try? loadPageBundle(at: $0)
            }
            .sorted { $0.slug < $1.slug }

        for pageBundle in pageBundles {
            print(pageBundle.slug, "-", pageBundle.type)
        }

        return pageBundles
    }


    func loadPageBundle(
        at path: String
    ) throws -> PageBundle? {
        let url = contentUrl.appendingPathComponent(path)
        guard fileManager.fileExists(at: url) else {
            return nil
        }

        do {
            let fileName = url.lastPathComponent
            let location = String(url.path.dropLast(fileName.count))
            let id = String(path.dropLast(fileName.count + 1))

            let lastModification = try fileManager.modificationDate(at: url)
            
            let dirUrl = URL(fileURLWithPath: location)

            // MARK: - load markdown + front matter data

            let rawMarkdown = try String(contentsOf: url, encoding: .utf8)
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
                let da = try frontMatterParser.load(yaml: yaml, as: [[String: Any]].self) ?? []
                data += da
            }
            
            // MARK: - load data & filter based on draft, publication, expiration
            
            let draft = frontMatter.value("draft", as: Bool.self) ?? false
            
            /// filter out draft
            if draft {
                return nil
            }

            let dateFormatter = DateFormatters.contentLoader
            dateFormatter.dateFormat = self.config.site.dateFormat

            var publication: Date = now
            if
                let rawDate = frontMatter["publication"] as? String,
                let date = dateFormatter.date(from: rawDate)
            {
                publication = date
            }
            
            /// filter out unpublished
            if publication > now {
                return nil
            }
            
            var expiration: Date? = nil
            if
                let rawDate = frontMatter["expiration"] as? String,
                let date = dateFormatter.date(from: rawDate)
            {
                expiration = date
            }
            
            /// filter out expired
            if let expiration, expiration < now {
                return nil
            }
            
            
            // MARK: - load material metadata
            
            let slug = frontMatter.string("slug")?.emptyToNil ?? id
            let type = frontMatter.string("type")?.emptyToNil ?? "page"
            let title = frontMatter.string("title") ?? ""
            let description = frontMatter.string("description") ?? ""
            let image = frontMatter.string("image")?.emptyToNil
            
            let template = frontMatter.string("template") ?? "TODO"
            let assetsPath = frontMatter.string("assets.path")?.emptyToNil
            let userDefined = frontMatter.dict("userDefined")
            let redirects = frontMatter.value(
                "redirects.from",
                as: [String].self
            ) ?? []
            let noindex = frontMatter.value("noindex", as: Bool.self) ?? false
            let canonical = frontMatter.string("canonical")?.emptyToNil
            
            var hreflang = frontMatter.value(
                "hreflang",
                as: [[String: String]].self
            )?.compactMap { dict -> Context.Metadata.Hreflang? in
                guard
                    let lang = dict["lang"]?.emptyToNil,
                    let url = dict["url"]?.emptyToNil
                else {
                    return nil
                }
                return .init(lang: lang, url: url)
            }
            /// fallback to empty array if key is explicitly defined
            if hreflang == nil, frontMatter["hreflang"] != nil {
                hreflang = []
            }

            let assetsUrl = dirUrl
                .appendingPathComponent(assetsPath ?? id)
            
            let styleCss = assetsUrl
                .appendingPathComponent("style.css")
            
            let mainJs = assetsUrl
                .appendingPathComponent("main.js")
            
            // NOTE: hacky solution...
            var imageUrl: String? = nil
            if let image, fileManager.fileExists(
                at: dirUrl.appendingPathComponent(
                    image
                )
            ) {
                imageUrl = image
            }
            
//            print(image)
//            print(imageUrl)
//            print("---")
            
            var css: [String] = []
            if fileManager.fileExists(at: styleCss) {
                let cssFile = "./" + id + "/style.css"
                css.append(cssFile)
            }
            let cssFiles = frontMatter.value(
                "css",
                as: [String].self
            ) ?? []
            css += cssFiles
            
            var js: [String] = []
            if fileManager.fileExists(at: mainJs) {
                let jsFile = "./" + id + "/main.js"
                js.append(jsFile)
            }

            let jsFiles = frontMatter.value(
                "css",
                as: [String].self
            ) ?? []
            js += jsFiles

//                print(id)
//                print(fileName)
//                print(slug)
//                print(location)
//                print(assetsFolder ?? id)
//                print("---")
            
            // TODO: proper asset resolution
            let assets = fileManager.recursivelyListDirectory(at: assetsUrl)
            
            let finalSlug = slug.safeSlug(prefix: nil)

            
            return .init(
                url: .init(fileURLWithPath: location),
                slug: finalSlug,
                type: type,
                title: title,
                description: description,
                image: imageUrl,
                draft: draft,
                publication: publication,
                expiration: expiration,
                css: css,
                js: js,
                template: template,
                assetsPath: assetsPath ?? id,
                lastModification: lastModification,
                redirects: redirects,
                userDefined: userDefined,
                data: data,
                frontMatter: frontMatter,
                markdown: rawMarkdown.dropFrontMatter(),
                assets: assets,
                noindex: noindex,
                canonical: canonical,
                hreflang: hreflang
            )
        }
        catch {
            throw Error.pageBundle(error)
        }
    }
}

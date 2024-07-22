//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation

struct PageBundle {

    struct Redirect {

        enum Code: Int, CaseIterable {
            case movedPermanently = 301
            case seeOther = 303
            case permanentRedirect = 308
        }

        let from: String
        let code: Code
    }

    struct Assets {
        let path: String
    }

    struct Context {

        struct Hreflang {
            let lang: String
            let url: String
        }

        struct DateValue {
            let html: String
            let rss: String
            let sitemap: String
        }

        let slug: String
        let permalink: String
        let title: String
        let description: String
        let imageUrl: String?

        let lastModification: DateValue
        let publication: DateValue
        let expiration: DateValue?

        // head
        let noindex: Bool
        let canonical: String?
        let hreflang: [Hreflang]
        let css: [String]
        let js: [String]

        let userDefined: [String: Any]

        var dict: [String: Any] {
            var result: [String: Any] = [:]

            result["slug"] = slug
            result["permalink"] = permalink
            result["title"] = title
            result["description"] = description
            result["imageUrl"] = imageUrl ?? false

            result["lastModification"] = lastModification
            result["publication"] = publication
            result["expiration"] = expiration ?? false

            result["noindex"] = noindex
            result["canonical"] = canonical ?? false
            result["hreflang"] = hreflang
            result["css"] = css
            result["js"] = js

            return result.recursivelyMerged(with: userDefined)
        }
    }

    /// The url of the page bundle.
    let url: URL
    let frontMatter: [String: Any]
    let markdown: String

    let type: String
    let lastModification: Date
    let publication: Date
    let expiration: Date?
    let template: String
    let output: String?
    let assets: Assets
    let redirects: [Redirect]

    //    let userDefined: [String: Any]
    //    let data: [[String: Any]]

    let context: Context

}

extension PageBundle {

    //    var context: [String: Any] {
    //        var result: [String: Any] = [:]
    ////        var result: [String: Any] = frontMatter
    //        result["slug"] = slug
    //        result["permalink"] = permalink
    //        result["title"] = title
    //        result["description"] = description
    //        result["imageUrl"] = image  // imageUrl() vs frontMatter["image"] ?
    //        if image == nil {
    //            result["imageUrl"] = false
    //        }
    //        // TODO: date format
    //        result["publication"] = publication
    //        result["expiration"] = expiration
    //        result["lastModification"] = lastModification
    //        result["css"] = cssUrls()
    //        result["js"] = jsUrls()
    //        result["noindex"] = noindex
    //        result["canonical"] = canonical
    //        result["hreflang"] = hreflang
    //        // TODO: better user defaults
    //        return
    //            result
    //            .recursivelyMerged(with: userDefined)
    //    }

    /// Returns the context aware identifier, the last component of the slug
    ///
    /// Can be used when referencing contents, e.g.
    /// slug: docs/installation
    /// type: category
    /// contextAwareIdentifier: installation
    /// This way content can be identified, when knowing the type & id
    var contextAwareIdentifier: String {
        .init(context.slug.split(separator: "/").last ?? "")
    }

    func referenceIdentifiers(
        for key: String
    ) -> [String] {
        var refIds: [String] = []
        if let ref = frontMatter[key] as? String {
            refIds.append(ref)
        }
        refIds += frontMatter[key] as? [String] ?? []
        return refIds
    }

    func referenceIdentifiers(
        for key: String,
        join: ContentType.Join
    ) -> [String] {
        var refIds: [String] = []
        switch join {
        case .one:
            if let ref = frontMatter[key] as? String {
                refIds.append(ref)
            }
        case .many:
            refIds = frontMatter[key] as? [String] ?? []
        }
        return refIds
    }

}

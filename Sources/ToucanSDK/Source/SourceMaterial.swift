//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation

struct SourceMaterial {
    let url: URL
    
    let slug: String
    let title: String
    let description: String
    let image: String?
    let draft: Bool
    let publication: Date
    let expiration: Date?
    
    let css: [String]
    let js: [String]

    let template: String
    let assetsPath: String
    let lastModification: Date
    let redirects: [String]
    let userDefined: [String: Any]
    let data: [[String: Any]]

    let frontMatter: [String: Any]
    let markdown: String
    
    let assets: [String]
    let noindex: Bool
    let canonical: String?
    let hreflang: [Context.Metadata.Hreflang]?
}

extension SourceMaterial {

    func updated(
        title: String? = nil,
        description: String? = nil,
        markdown: String? = nil,
        slug: String
    ) -> Self {
        .init(
            url: url,
            slug: slug,
            title: title ?? self.title,
            description: description ?? self.description,
            image: image,
            draft: draft,
            publication: publication,
            expiration: expiration,
            css: css,
            js: js,
            template: template,
            assetsPath: assetsPath,
            lastModification: lastModification,
            redirects: redirects,
            userDefined: userDefined,
            data: data,
            frontMatter: frontMatter,
            markdown: markdown ?? self.markdown,
            assets: assets,
            noindex: noindex,
            canonical: canonical,
            hreflang: hreflang
        )
    }
    
    func resolveAsset(_ value: String?) -> String? {
        let prefix = "./\(assetsPath)"
        guard let value, value.hasPrefix(prefix) else {
            return value
        }
        let base = String(value.dropFirst(prefix.count))
        return "/assets/" + slug + "/" + base.safeSlug(prefix: nil)
    }
    
    func imageUrl() -> String? {
        resolveAsset(image)
    }
    
    func cssUrls() -> [String] {
        css.compactMap { resolveAsset($0) }
    }
    
    func jsUrls() -> [String] {
        js.compactMap { resolveAsset($0) }
    }
}

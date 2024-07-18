//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation

struct PageBundle {
    let url: URL
    
    let slug: String
    
    let type: String
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

extension PageBundle {

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

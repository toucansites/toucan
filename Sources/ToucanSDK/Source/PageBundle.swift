//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation

/// A page bundle representing a subpage for a website.
struct PageBundle {

    struct DateValue {
        let html: String
        let rss: String
        let sitemap: String
    }
    
    let id: String
    let url: URL

    let slug: String
    let permalink: String
    let title: String
    let description: String
    let publication: Date

    let contentType: ContentType
    let lastModification: Date
    let config: Config
    let frontMatter: [String: Any]
    let properties: [String: Any]
    let relations: [String: Any]
    let markdown: String
    
    
    var dict: [String: Any] { [:] }
}

extension PageBundle {

    /// Returns the context aware identifier, the last component of the slug
    ///
    /// Can be used when referencing contents, e.g.
    /// slug: docs/installation
    /// type: category
    /// contextAwareIdentifier: installation
    /// This way content can be identified, when knowing the type & id
    var contextAwareIdentifier: String {
        .init(slug.split(separator: "/").last ?? "")
    }

    func convert(
        date: Date
    ) -> PageBundle.DateValue {
        let html = DateFormatters.baseFormatter
        //html.dateFormat = sourceConfig.config.site.dateFormat
        let rss = DateFormatters.rss
        let sitemap = DateFormatters.sitemap

        return .init(
            html: html.string(from: date),
            rss: rss.string(from: date),
            sitemap: sitemap.string(from: date)
        )
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

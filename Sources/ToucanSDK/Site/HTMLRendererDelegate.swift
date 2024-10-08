//
//  File.swift
//
//
//  Created by Tibor Bodecs on 23/05/2024.
//

import Markdown
import Foundation

struct HTMLRendererDelegate: MarkdownRenderer.Delegate {

    let config: Config
    let pageBundle: PageBundle

    func linkAttributes(_ link: String?) -> [String: String] {
        var attributes: [String: String] = [:]
        guard let link, !link.isEmpty else {
            return attributes
        }
        if !link.hasPrefix("."),
            !link.hasPrefix("/"),
            !link.hasPrefix(config.site.baseUrl)
        {
            attributes["target"] = "_blank"
        }
        return attributes
    }

    func imageOverride(_ image: Image) -> String? {
        let prefix = "./\(pageBundle.assets.path)/"
        guard
            let source = image.source,
            source.hasPrefix(prefix)
        else {
            return nil
        }

        let src = String(source.dropFirst(prefix.count))

        // TODO: better asset management for index page bundle
        let assetsDir = pageBundle.context.slug.isEmpty ? "" : "/assets/"
        let url = assetsDir + pageBundle.context.slug + "/" + src

        var title = ""
        if let ttl = image.title {
            title = #" title="\#(ttl)""#
        }

        return """
                <img src="\(url)" alt="\(image.plainText)"\(title)>
            """
    }
}

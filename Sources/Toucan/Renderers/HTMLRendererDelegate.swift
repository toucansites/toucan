//
//  File.swift
//
//
//  Created by Tibor Bodecs on 23/05/2024.
//

import Markdown
import Foundation

struct HTMLRendererDelegate: MarkdownToHTMLRenderer.Delegate {

    let site: Site
    let content: SourceMaterial
    let fileManager: FileManager = .default

    func linkAttributes(_ link: String?) -> [String: String] {
        var attributes: [String: String] = [:]
        guard let link, !link.isEmpty else {
            return attributes
        }
        if !link.hasPrefix("."),
            !link.hasPrefix("/"),
           !link.hasPrefix(site.source.config.site.baseUrl)
        {
            attributes["target"] = "_blank"
        }
        return attributes
    }

    func imageOverride(_ image: Image) -> String? {
        let prefix = "./\(content.assetsPath)"
        guard
            let source = image.source,
            source.hasPrefix(prefix)
        else {
            return nil
        }
        
        let src = String(source.dropFirst(prefix.count))
        
        let url = "/assets/" + content.slug + "/" + src
        
        var title = ""
        if let ttl = image.title {
            title = #" title="\#(ttl)""#
        }

        return """
            <img src="\(url)" alt="\(image.plainText)"\(title)>
        """
    }
}

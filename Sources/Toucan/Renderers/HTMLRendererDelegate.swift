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
    let content: Source.Content
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
        guard
            let source = image.source,
            source.hasPrefix("./")
//            let url = site.assetUrl(for: source, folder: folder)
        else {
            return nil
        }
        
        let src = String(source.dropFirst())
        
        let url = "/assets/" + content.slug + src
        
        var title = ""
        if let ttl = image.title {
            title = #" title="\#(ttl)""#
        }

        return """
            <img src="\(url)" alt="\(image.plainText)"\(title)>
        """
        
        
        
        //        var drk = ""
        //        if let darkUrl = site.assetUrl(
        //            for: source,
        //            folder: folder,
        //            variant: .dark
        //        ) {
        //            drk =
        //                #"<source srcset="\#(darkUrl)" media="(prefers-color-scheme: dark)">\#n\#t\#t"#
        //        }
        //        var title = ""
//                if let ttl = image.title {
//                    title = #" title="\#(ttl)""#
//                }
        //        return #"""
        //                <figure>
        //                   <picture>
        //                       \#(drk)<img class="post-image" src="\#(url)" alt="\#(image.plainText)"\#(title)>
        //                   </picture>
        //                </figure>
        //            """#
    }
}

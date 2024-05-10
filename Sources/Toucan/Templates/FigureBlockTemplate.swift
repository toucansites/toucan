//
//  File.swift
//
//
//  Created by Tibor Bodecs on 10/05/2024.
//

import Foundation

struct Figure {

}

struct FigureBlockTemplate: Template {

    let post: Post
    let templatesUrl: URL

    func render() throws -> String {
        let templateUrl =
            templatesUrl
            .appendingPathComponent("_blocks")
            .appendingPathComponent("figure.html")

        let template = try String(contentsOf: templateUrl)

        return template.replacingTemplateVariables(
            [
                "title": post.metatags.title,
                "permalink": post.slug,
                "image": post.metatags.imageUrl ?? "",
                "published": "\(post.publication)",
            ],
            "post"
        )
    }
}

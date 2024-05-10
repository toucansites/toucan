//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/05/2024.
//

import Foundation

struct PostBlockTemplate: Template {

    let post: Post
    let templatesUrl: URL

    func render() throws -> String {
        let templateUrl =
            templatesUrl
            .appendingPathComponent("_blocks")
            .appendingPathComponent("post.html")

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

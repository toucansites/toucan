//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 06. 17..
//

@testable import ToucanSource

extension Mocks.Templates {
    
    static func metadata(
        generatorVersions: [String] = ["1.0.0-beta.5"]
    ) -> Template.Metadata {
        let url = "http://localhost:8080/"
        
        return .init(
            name: "Test Template",
            description: "Test Template description",
            url: url,
            version: "1.0.0",
            generatorVersions: generatorVersions,
            license: .init(
                name: "Test License",
                url: url
            ),
            author: .init(
                name: "Test Template Author",
                url: url
            ),
            demo: .init(
                url: url
            ),
            tags: [
                "blog",
                "adaptive-colors"
            ]
        )
    }
    
    static func example(
        generatorVersions: [String] = ["1.0.0-beta.5"]
    ) -> Template {
        .init(
            metadata: Self.metadata(generatorVersions: generatorVersions),
            components: .init(
                assets: [
                    "css/theme.css",
                    "css/variables.css",
                ],
                views: [
                    .init(
                        id: "pages.404",
                        path: "pages/404.mustache",
                        contents: Mocks.Views.notFound()
                    ),
                    .init(
                        id: "blog.post.default",
                        path: "blog/post/default.mustache",
                        contents: Mocks.Views.post()
                    ),
                    .init(
                        id: "blog.author.default",
                        path: "blog/author/default.mustache",
                        contents: Mocks.Views.author()
                    ),
                    .init(
                        id: "html",
                        path: "html.mustache",
                        contents: Mocks.Views.html()
                    ),
                ]
            ),
            overrides: .init(
                assets: [],
                views: []
            ),
            content: .init(
                assets: [
                    "splash/750x1334.png",
                    "splash/750x1334~dark.png",
                    "icons/320.png",
                    "CNAME",
                ],
                views: []
            )
        )
    }
}

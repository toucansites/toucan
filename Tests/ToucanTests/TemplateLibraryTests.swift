//
//  File.swift
//
//
//  Created by Tibor Bodecs on 10/05/2024.
//

import XCTest
@testable import Toucan

struct SiteContext {
    let baseUrl: String
    let name: String
    let tagline: String
    let imageUrl: String?
    let language: String?
}

struct MetadataContext {
    let permalink: String
    let title: String
    let description: String
    let imageUrl: String?
}

struct TemplateContext<T> {
    let site: SiteContext
    let metadata: MetadataContext
    let contents: T
}

struct PostCardContext {
    let title: String
    let exceprt: String
    let date: String
    let figure: FigureContext?
}

struct FigureContext {
    let src: String
    let darkSrc: String?
    let alt: String?
    let title: String?
}

final class TemplateLibraryTests: XCTestCase {

    func testHomePageTemplate() throws {

        let path =
            "/"
            + #file
            .split(separator: "/")
            .dropLast(2)
            .joined(separator: "/")

        let baseUrl = URL(fileURLWithPath: path)
        let srcUrl = baseUrl.appendingPathComponent("src")
        let distUrl = baseUrl.appendingPathComponent("dist")
        let contentsUrl = srcUrl.appendingPathComponent("contents")
        let templatesUrl = srcUrl.appendingPathComponent("templates")

        let loader = ContentLoader(path: contentsUrl.path)

        let site = try loader.load()

        let templates = try TemplateLibrary(templatesUrl: templatesUrl)

        let context = TemplateContext(
            site: .init(
                baseUrl: site.baseUrl,
                name: site.name,
                tagline: site.tagline,
                imageUrl: site.imageUrl,
                language: site.language
            ),
            metadata: .init(
                permalink: site.baseUrl + "slug-comes-here/",
                title: "Lorem ipsum",
                description: "doloor sit amet",
                imageUrl: nil
            ),
            contents: [
                PostCardContext(
                    title: "foo",
                    exceprt: "foo",
                    date: "2022",
                    figure: .init(
                        src: "http://lorempixel.com/light.jpg",
                        darkSrc: "http://lorempixel.com/dark.jpg",
                        alt: "foo",
                        title: "lorem foo"
                    )
                )
            ]

        )

        let res = try templates.render(
            template: "pages.home",
            with: context
        )
        print(res!)
    }

}

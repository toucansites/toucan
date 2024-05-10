//
//  File.swift
//
//
//  Created by Tibor Bodecs on 10/05/2024.
//

import XCTest
@testable import Toucan

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

        let context = PageContext(
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
            content: [
                PostContext(
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

    func testSinglePageTemplate() throws {

        let path =
            "/"
            + #file
            .split(separator: "/")
            .dropLast(2)
            .joined(separator: "/")

        let baseUrl = URL(fileURLWithPath: path)
        let srcUrl = baseUrl.appendingPathComponent("src")
        let contentsUrl = srcUrl.appendingPathComponent("contents")
        let templatesUrl = srcUrl.appendingPathComponent("templates")

        let loader = ContentLoader(path: contentsUrl.path)

        let site = try loader.load()

        let templates = try TemplateLibrary(templatesUrl: templatesUrl)

        let context = PageContext(
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
            content: "just a <b>simple</b> page"

        )

        let res = try templates.render(
            template: "pages.single.page",
            with: context
        )
        print(res!)
    }

    func testSinglePostTemplate() throws {

        let path =
            "/"
            + #file
            .split(separator: "/")
            .dropLast(2)
            .joined(separator: "/")

        let baseUrl = URL(fileURLWithPath: path)
        let srcUrl = baseUrl.appendingPathComponent("src")
        let contentsUrl = srcUrl.appendingPathComponent("contents")
        let templatesUrl = srcUrl.appendingPathComponent("templates")

        let loader = ContentLoader(path: contentsUrl.path)

        let site = try loader.load()

        let templates = try TemplateLibrary(templatesUrl: templatesUrl)

        let context = PageContext(
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
            content: SinglePostContext(
                title: "foo",
                exceprt: "bar",
                date: "2025",
                figure: .init(
                    src: "http://lorempixel.com/light.jpg",
                    darkSrc: "http://lorempixel.com/dark.jpg",
                    alt: "foo",
                    title: "lorem foo"
                ),
                tags: [
                    .init(permalink: "https://bb.com/foo", name: "Foo")
                ],
                body: "<b>lorem ipsum</b> dolor sit amet"
            )

        )

        let res = try templates.render(
            template: "pages.single.post",
            with: context
        )
        print(res!)
    }

}

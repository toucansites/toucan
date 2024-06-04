//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/05/2024.
//

import Foundation

struct SiteGenerator {

    let site: Site

    let templatesUrl: URL
    let outputUrl: URL

    let fileManager: FileManager = .default

    //    func generateSiteDirectories() {
    //        let authorsDirUrl =
    //            outputUrl
    //            .appendingPathComponent(Directories.authors)
    //        try fileManager.createDirectory(at: authorsDirUrl)
    //
    //        for author in site.authors {
    //            let authorUrl = authorsDirUrl.appendingPathComponent(author.slug)
    //            try fileManager.createDirectory(at: authorUrl)
    //        }
    //
    //        for page in site.customPages {
    //            let pageUrl = outputUrl.appendingPathComponent(page.slug)
    //            try fileManager.createDirectory(at: pageUrl)
    //        }
    //
    //        let postsDirUrl = outputUrl.appendingPathComponent(Directories.posts)
    //        try fileManager.createDirectory(at: postsDirUrl)
    //
    //        for post in site.posts {
    //            let postUrl = postsDirUrl.appendingPathComponent(post.slug)
    //            try fileManager.createDirectory(at: postUrl)
    //        }
    //
    //        let postsPageDirUrl =
    //            postsDirUrl
    //            .appendingPathComponent(Directories.postsPage)
    //        for (index, _) in site.postChunks.enumerated() {
    //            let pageIndex = index + 1
    //            let pageDirUrl =
    //                postsPageDirUrl
    //                .appendingPathComponent(String(pageIndex))
    //            try fileManager.createDirectory(at: pageDirUrl)
    //        }
    //
    //        let tagsDirUrl = outputUrl.appendingPathComponent(Directories.tags)
    //        try fileManager.createDirectory(at: tagsDirUrl)
    //
    //        for tag in site.tags {
    //            let tagUrl = tagsDirUrl.appendingPathComponent(tag.slug)
    //            try fileManager.createDirectory(at: tagUrl)
    //        }
    //    }

    /// generates all the html & xml files
    func generate() throws {
        // TODO: check reserved slugs
        let state = site.buildState()

        let renderer = try MustacheToHTMLRenderer(
            templatesUrl: templatesUrl
        )
        try generateHomePage(renderer, state)
        try generateNotFoundPage(renderer, state)
        try generateBlogHomePage(renderer, state)

        try generateCustomPages(renderer, state)
        try generateTagPages(renderer, state)
        try generateAuthorPages(renderer, state)
        try generatePostPages(renderer, state)

        try generateRSS(renderer, state)
        try generateSitemap(renderer, state)
    }

    // MARK: -

    func generateHomePage(
        _ renderer: MustacheToHTMLRenderer,
        _ state: Site.State
    ) throws {

        let customPageUrl =
            outputUrl
            .appendingPathComponent(state.home.page.slug)
            .appendingPathComponent(Toucan.Files.index)

        try fileManager.createParentFolderIfNeeded(for: customPageUrl)

        try renderer.render(
            template: state.home.template,
            with: state.home,
            to: customPageUrl
        )
    }

    func generateNotFoundPage(
        _ renderer: MustacheToHTMLRenderer,
        _ state: Site.State
    ) throws {

        let notFoundUrl =
            outputUrl
            .appendingPathComponent(Toucan.Files.notFound)

        try fileManager.createParentFolderIfNeeded(for: notFoundUrl)

        try renderer.render(
            template: state.notFound.template,
            with: state.notFound,
            to: notFoundUrl
        )
    }

    func generateCustomPages(
        _ renderer: MustacheToHTMLRenderer,
        _ state: Site.State
    ) throws {

        for page in state.pages {
            let customPageUrl =
                outputUrl
                .appendingPathComponent(page.page.slug)
                .appendingPathComponent(Toucan.Files.index)

            try fileManager.createParentFolderIfNeeded(for: customPageUrl)

            try renderer.render(
                template: page.template,
                with: page,
                to: customPageUrl
            )
        }
    }

    // MARK: - rss & sitemap

    func generateRSS(
        _ renderer: MustacheToHTMLRenderer,
        _ state: Site.State
    ) throws {
        let rssUrl =
            outputUrl
            .appendingPathComponent(Toucan.Files.rss)

        try fileManager.createParentFolderIfNeeded(for: rssUrl)

        try renderer.render(
            template: "rss",
            with: state.rss,
            to: rssUrl
        )
    }

    func generateSitemap(
        _ renderer: MustacheToHTMLRenderer,
        _ state: Site.State
    ) throws {

        let sitemapUrl =
            outputUrl
            .appendingPathComponent(Toucan.Files.sitemap)

        try fileManager.createParentFolderIfNeeded(for: sitemapUrl)

        try renderer.render(
            template: "sitemap",
            with: state.sitemap,
            to: sitemapUrl
        )
    }

    // MARK: - blog

    func generateBlogHomePage(
        _ renderer: MustacheToHTMLRenderer,
        _ state: Site.State
    ) throws {

        let blogHomePageUrl =
            outputUrl
            .appendingPathComponent(state.blog.home.page.slug)
            .appendingPathComponent(Toucan.Files.index)

        try fileManager.createParentFolderIfNeeded(for: blogHomePageUrl)

        try renderer.render(
            template: state.blog.home.template,
            with: state.blog.home,
            to: blogHomePageUrl
        )
    }

    func generateTagPages(
        _ renderer: MustacheToHTMLRenderer,
        _ state: Site.State
    ) throws {

        let tagListUrl =
            outputUrl
            .appendingPathComponent(state.blog.tag.list.page.slug)
            .appendingPathComponent(Toucan.Files.index)

        try fileManager.createParentFolderIfNeeded(for: tagListUrl)

        try renderer.render(
            template: state.blog.tag.list.template,
            with: state.blog.tag.list,
            to: tagListUrl
        )

        for tag in state.blog.tag.details {
            let tagPageUrl =
                outputUrl
                .appendingPathComponent(tag.page.slug)
                .appendingPathComponent(Toucan.Files.index)

            try fileManager.createParentFolderIfNeeded(for: tagPageUrl)

            try renderer.render(
                template: tag.template,
                with: tag,
                to: tagPageUrl
            )
        }
    }

    func generateAuthorPages(
        _ renderer: MustacheToHTMLRenderer,
        _ state: Site.State
    ) throws {

        let authorsListUrl =
            outputUrl
            .appendingPathComponent(state.blog.author.list.page.slug)
            .appendingPathComponent(Toucan.Files.index)

        try fileManager.createParentFolderIfNeeded(for: authorsListUrl)

        try renderer.render(
            template: state.blog.author.list.template,
            with: state.blog.author.list,
            to: authorsListUrl
        )

        for author in state.blog.author.details {
            let authorPageUrl =
                outputUrl
                .appendingPathComponent(author.page.slug)
                .appendingPathComponent(Toucan.Files.index)

            try fileManager.createParentFolderIfNeeded(for: authorPageUrl)

            try renderer.render(
                template: author.template,
                with: author,
                to: authorPageUrl
            )
        }
    }

    func generatePostPages(
        _ renderer: MustacheToHTMLRenderer,
        _ state: Site.State
    ) throws {
        /// render post list pages
        for postListPage in state.blog.post.pages {
            let postListPageUrl =
                outputUrl
                .appendingPathComponent(postListPage.page.slug)
                .appendingPathComponent(Toucan.Files.index)

            try fileManager.createParentFolderIfNeeded(for: postListPageUrl)

            try renderer.render(
                template: postListPage.template,
                with: postListPage,
                to: postListPageUrl
            )
        }

        /// render post detail pages
        for post in state.blog.post.details {
            let postPageUrl =
                outputUrl
                .appendingPathComponent(post.page.slug)
                .appendingPathComponent(Toucan.Files.index)

            try fileManager.createParentFolderIfNeeded(for: postPageUrl)

            try renderer.render(
                template: post.template,
                with: post,
                to: postPageUrl
            )
        }
    }
}

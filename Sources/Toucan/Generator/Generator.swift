//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/05/2024.
//

import Foundation

struct Generator {

    let site: Site
    let templatesUrl: URL
    let outputUrl: URL

    /// generates all the html & xml files
    func generate() throws {
        // TODO: check reserved slugs
        let templates = try TemplateLibrary(
            site: site,
            templatesUrl: templatesUrl
        )

        let htmlRenderer = HTMLRenderer()
        try generatePostPages(templates, htmlRenderer: htmlRenderer)
        try generateTagPages(templates, htmlRenderer: htmlRenderer)
        try generateAuthorPages(templates, htmlRenderer: htmlRenderer)
        try generateCustomPages(templates, htmlRenderer: htmlRenderer)

        let indexUrl =
            outputUrl
            .appendingPathComponent(Toucan.Files.index)
        try templates.renderHomePage(to: indexUrl)

        let notFoundUrl =
            outputUrl
            .appendingPathComponent(Toucan.Files.notFound)
        try templates.renderNotFoundPage(to: notFoundUrl)

        let rssUrl =
            outputUrl
            .appendingPathComponent(Toucan.Files.rss)
        try templates.renderRSS(to: rssUrl)

        let sitemapUrl =
            outputUrl
            .appendingPathComponent(Toucan.Files.sitemap)
        try templates.renderSitemap(to: sitemapUrl)
    }

    // MARK: -

    func generateCustomPages(
        _ templates: TemplateLibrary,
        htmlRenderer: HTMLRenderer
    ) throws {

        for page in site.customPages {
            let customPageUrl =
                outputUrl
                .appendingPathComponent(page.slug)
                .appendingPathComponent(Toucan.Files.index)

            let pageBody = htmlRenderer.render(markdown: page.markdown)

            try templates.renderSinglePage(
                page: page,
                body: pageBody,
                to: customPageUrl
            )
        }
    }

    func generateTagPages(
        _ templates: TemplateLibrary,
        htmlRenderer: HTMLRenderer
    ) throws {

        let tagsDirUrl =
            outputUrl
            .appendingPathComponent(Toucan.Directories.tags)

        for tag in site.tags {

            let tagPageDirUrl =
                tagsDirUrl
                .appendingPathComponent(tag.slug)

            let tagPageUrl =
                tagPageDirUrl
                .appendingPathComponent(Toucan.Files.index)

            let tagBody = htmlRenderer.render(markdown: tag.markdown)

            try templates.renderSingleTag(
                tag: tag,
                body: tagBody,
                to: tagPageUrl
            )
        }

        let tagsUrl = tagsDirUrl.appendingPathComponent(Toucan.Files.index)
        try templates.renderTagsPage(to: tagsUrl)
    }

    func generateAuthorPages(
        _ templates: TemplateLibrary,
        htmlRenderer: HTMLRenderer
    ) throws {

        let authorsDirUrl =
            outputUrl
            .appendingPathComponent(Toucan.Directories.authors)

        for author in site.authors {

            let authorPageDirUrl =
                authorsDirUrl
                .appendingPathComponent(author.slug)

            let tagPageUrl =
                authorPageDirUrl
                .appendingPathComponent(Toucan.Files.index)

            let tagBody = htmlRenderer.render(markdown: author.markdown)

            try templates.renderSingleAuthor(
                author: author,
                body: tagBody,
                to: tagPageUrl
            )
        }

        let authorsUrl =
            authorsDirUrl
            .appendingPathComponent(Toucan.Files.index)
        try templates.renderAuthorsPage(to: authorsUrl)
    }

    func generatePostPages(
        _ templates: TemplateLibrary,
        htmlRenderer: HTMLRenderer
    ) throws {
        let postPages = site.postChunks

        let postsDirUrl =
            outputUrl
            .appendingPathComponent(Toucan.Directories.posts)

        for (index, posts) in postPages.enumerated() {
            let pageIndex = index + 1

            let postPageDirUrl =
                postsDirUrl
                .appendingPathComponent(Toucan.Directories.postsPage)
                .appendingPathComponent(String(pageIndex))

            let postPageUrl =
                postPageDirUrl
                .appendingPathComponent(Toucan.Files.index)

            // TODO: add canonical if index == 0
            try templates.renderPostsPage(
                posts: Array(posts),
                pageIndex: index,
                pageCount: postPages.count,
                to: postPageUrl
            )

            if index == 0 {
                let postsUrl =
                    postsDirUrl
                    .appendingPathComponent(Toucan.Files.index)
                try templates.renderPostsPage(
                    posts: Array(posts),
                    pageIndex: index,
                    pageCount: postPages.count,
                    to: postsUrl
                )
                let postPageUrl =
                    postsDirUrl
                    .appendingPathComponent(Toucan.Directories.postsPage)
                    .appendingPathComponent(Toucan.Files.index)
                try templates.renderPostsPage(
                    posts: Array(posts),
                    pageIndex: index,
                    pageCount: postPages.count,
                    to: postPageUrl
                )
            }

            for post in posts {
                let postUrl =
                    postsDirUrl
                    .appendingPathComponent(post.slug)
                    .appendingPathComponent(Toucan.Files.index)
                let postBody = htmlRenderer.render(markdown: post.markdown)

                try templates.renderSinglePost(
                    post: post,
                    body: postBody,
                    to: postUrl
                )
            }
        }
    }
}

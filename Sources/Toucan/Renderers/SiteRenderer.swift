//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/05/2024.
//

import Foundation

struct SiteRenderer {

    let site: Site

    let templatesUrl: URL

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

    func render() throws {
        //        let state = site.buildState()

        let renderer = try MustacheToHTMLRenderer(
            templatesUrl: templatesUrl
        )

        let home = site.home()
        let rss = site.rss()
        let sitemap = site.sitemap()
        
        try render(renderer, home)
        try render(renderer, rss)
        try render(renderer, sitemap)
        
        print(site.tagList())
        if let tags = site.tagList() {
            try render(renderer, tags)
        }

        //        try generateNotFoundPage(renderer, state)
        //        try generateBlogHomePage(renderer, state)
        //
        //        try generateCustomPages(renderer, state)
        //        try generateTagPages(renderer, state)
        //        try generateAuthorPages(renderer, state)
        //        try generatePostPages(renderer, state)
        //
        //        try generateRSS(renderer, state)
        //        try generateSitemap(renderer, state)
    }

    // MARK: -

    func render<T>(
        _ renderer: MustacheToHTMLRenderer,
        _ renderable: Renderable<T>
    ) throws {

        try fileManager.createParentFolderIfNeeded(
            for: renderable.destination
        )
        try renderer.render(
            template: renderable.template,
            with: renderable.context,
            to: renderable.destination
        )
    }
}

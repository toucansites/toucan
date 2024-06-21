//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/05/2024.
//

import Foundation

struct SiteGenerator {

    let site: Site

    let publicFilesUrl: URL
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

    func copyPublicFiles() throws {
        for file in fileManager.listDirectory(at: publicFilesUrl) {
            try fileManager.copy(
                from: publicFilesUrl.appendingPathComponent(file),
                to: site.destinationUrl.appendingPathComponent(file)
            )
        }
    }

    func render() throws {
        let renderer = try MustacheToHTMLRenderer(
            templatesUrl: templatesUrl
        )
        
        // reset
        try fileManager.delete(at: site.destinationUrl)
        try fileManager.createDirectory(at: site.destinationUrl)

        // copy public files first
        try copyPublicFiles()

        // render pages
        let home = site.home()
        let notFound = site.notFound()
        try render(renderer, home)
        try render(renderer, notFound)
        
        // render rss & sitemap
        let rss = site.rss()
        let sitemap = site.sitemap()
        try render(renderer, rss)
        try render(renderer, sitemap)
        
        // render blog
        if let renderable = site.blogHome() {
            try render(renderer, renderable)
        }

        // render authors
        if let renderable = site.authorList() {
            try render(renderer, renderable)
        }
        for renderable in site.authorDetails() {
            try render(renderer, renderable)
        }
        
        // render tags
        if let renderable = site.tagList() {
            try render(renderer, renderable)
        }
        for renderable in site.tagDetails() {
            try render(renderer, renderable)
        }
        
        // custom pages
        for renderable in site.customPages() {
            try render(renderer, renderable)
        }
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

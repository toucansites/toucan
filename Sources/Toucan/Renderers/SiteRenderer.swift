//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 21/06/2024.
//

import Foundation

struct SiteRenderer {

    let site: Site

    let templatesUrl: URL
    let overridesUrl: URL

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
        let renderer = try MustacheToHTMLRenderer(
            templatesUrl: templatesUrl,
            overridesUrl: overridesUrl
        )
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
        
        // render posts
        for renderable in site.postListPaginated() {
            try render(renderer, renderable)
        }
        for renderable in site.postDetails() {
            try render(renderer, renderable)
        }
        
        // custom pages
        for renderable in site.customPages() {
            try render(renderer, renderable)
        }
        
        // docs
        if let docsHome = site.docsHome() {
            try render(renderer, docsHome)
        }
        
        // docs categories
        if let docsCategoryList = site.docsCategoryList() {
            try render(renderer, docsCategoryList)
        }
        for renderable in site.docsCategoryDetails() {
            try render(renderer, renderable)
        }
        
        // docs guides
        if let docsGuidList = site.docsGuideList() {
            try render(renderer, docsGuidList)
        }
        for renderable in site.docsGuideDetails() {
            try render(renderer, renderable)
        }
        
        // TODO: move this
        struct Redirect {
            let url: String
        }
        for content in site.source.materials.all() {
            for slug in content.redirects {
                try render(renderer,
                    .init(
                        template: "redirect",
                        context: Redirect(
                            url: site.permalink(content.slug)
                        ),
                        destination: site.destinationUrl
                            .appendingPathComponent(slug)
                            .appendingPathComponent("index.html")
                    )
                )
            }
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

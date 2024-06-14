//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 14/06/2024.
//

import Foundation

extension Site {

    struct State {

        struct Renderable<T> {
            let template: String
            let context: T
            let destination: URL
        }

        struct Main {
            let home: Renderable<HTML<HomeState>>
            let notFound: Renderable<HTML<Void>>
            let rss: Renderable<RSS>
            let sitemap: Renderable<Sitemap>
        }

        struct Blog {

            struct Author {
                let list: Renderable<HTML<AuthorListState>>?
                let details: [Renderable<HTML<AuthorDetailState>>]
            }
            
            struct Tag {
                let list: Renderable<HTML<TagListState>>?
                let details: [Renderable<HTML<TagDetailState>>]
            }
            
            struct Post {
                let pages: [Renderable<HTML<PostListState>>]
                let details: [Renderable<HTML<PostDetailState>>]
            }
            
            let home: Renderable<HTML<String>>?
            let author: Author
            let tag: Tag
            let post: Post
        }
        
        struct Docs {

            struct Category {
                let list: Renderable<HTML<Void>>?
                let details: [Renderable<HTML<Void>>]
            }
            
            struct Guide {
                let list: Renderable<HTML<Void>>?
                let details: [Renderable<HTML<Void>>]
            }

            let home: Renderable<HTML<Void>>?
            let categories: [Renderable<HTML<Void>>]
            let guides: [Renderable<HTML<Void>>]
            
        }

        let main: Main
        let blog: Blog
        let docs: Docs
        let pages: [Renderable<HTML<PageDetailState>>]
    }
}

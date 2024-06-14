//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 14/06/2024.
//

import Foundation

extension Site {

    struct State {
        
        struct Blog {
            struct Author {
                let list: AuthorListHTMLPageState
                let details: [AuthorDetailHTMLPageState]
            }
            
            struct Tag {
                let list: TagListHTMLPageState
                let details: [TagDetailHTMLPageState]
            }
            
            struct Post {
                let pages: [PostListHTMLPageState]
                let details: [PostDetailHTMLPageState]
            }
            
            let home: BlogHTMLPageState
            let post: Post
            let tag: Tag
            let author: Author
        }
        
        let home: HomeHTMLPageState
        let notFound: NotFoundHTMLPageState
        let blog: Blog
        let pages: [PageDetailHTMLPageState]
        let rss: RSSState
        let sitemap: SitemapState
    }
}

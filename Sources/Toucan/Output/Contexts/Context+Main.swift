//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Context {
    
    struct Main {

        struct Home {
            let featured: [Blog.Post.Item]
            let posts: [Blog.Post.Item]
            let authors: [Blog.Author.Item]
            let tags: [Blog.Tag.Item]
            let pages: [Pages.Custom]
        }
    }
}


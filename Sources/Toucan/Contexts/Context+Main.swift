//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Context {
    
    struct Main {

        struct Home {
            let featured: [Blog.Post]
            let posts: [Blog.Post]
            let authors: [Blog.Author]
            let tags: [Blog.Tag]
            let pages: [Pages.Custom]
        }
    }
}


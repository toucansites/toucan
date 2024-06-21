//
//  State+Blog.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Renderables {

    struct Blog {

        struct Author {
            let list: Renderable<Output.HTML<Context.Blog.Author.List>>?
            let details: [Renderable<Output.HTML<Context.Blog.Author.Detail>>]
        }

        struct Tag {
            let list: Renderable<Output.HTML<Context.Blog.Tag.List>>?
            let details: [Renderable<Output.HTML<Context.Blog.Tag.Detail>>]
        }

        struct Post {
            let pages: [Renderable<Output.HTML<Context.Blog.Post.List>>]
            let details: [Renderable<Output.HTML<Context.Blog.Post.Detail>>]
        }

        let home: Renderable<Output.HTML<Context.Blog.Home>>?
        let author: Author
        let tag: Tag
        let post: Post
    }
}


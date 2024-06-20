//
//  State+Blog.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Renderables {

    struct Blog {

        struct Author {
            let list: Renderable<Output.HTML<State.Blog.Author.List>>?
            let details: [Renderable<Output.HTML<State.Blog.Author.Detail>>]
        }

        struct Tag {
            let list: Renderable<Output.HTML<State.Blog.Tag.List>>?
            let details: [Renderable<Output.HTML<State.Blog.Tag.Detail>>]
        }

        struct Post {
            let pages: [Renderable<Output.HTML<State.Blog.Post.List>>]
            let details: [Renderable<Output.HTML<State.Blog.Post.Detail>>]
        }

        let home: Renderable<Output.HTML<State.Blog.Home>>?
        let author: Author
        let tag: Tag
        let post: Post
    }
}


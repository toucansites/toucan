//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Context {
    
    struct Blog {

        struct Post {

            struct List {
                let posts: [Post]
                let pagination: [Pagination]
            }

            struct Detail {
                let post: Post

                let related: [Post]
                let moreByAuthor: [Post]

                let next: Post?
                let prev: Post?
            }

            let permalink: String
            let title: String
            let excerpt: String
            let date: String
            let figure: Context.Figure??

            let tags: [Tag]
            let authors: [Author]
            let readingTime: Int
            let featured: Bool
            let userDefined: [String: Any]

        }

        struct Author {
            
            struct List {
                let authors: [Author]
            }

            struct Detail {
                let author: Author
                let posts: [Post]
            }
            
            let permalink: String
            let title: String
            let description: String
            let figure: Context.Figure?
            let numberOfPosts: Int
            let userDefined: [String: Any]
            let markdown: String
        }

        struct Tag {
            
            struct List {
                let tags: [Tag]
            }

            struct Detail {
                let tag: Tag
                let posts: [Post]
            }

            
            let permalink: String
            let title: String
            let description: String
            let figure: Context.Figure??
            let numberOfPosts: Int
            let userDefined: [String: Any]
            let markdown: String

        }

        struct Home {
            let featured: [Post]
            let posts: [Post]
            let authors: [Author]
            let tags: [Tag]
        }
    }
}

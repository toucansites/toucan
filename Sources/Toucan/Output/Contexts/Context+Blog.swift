//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Context {
    
    struct Blog {

        struct Home {
            let featured: [Post.Item]
            let posts: [Post.Item]
            let authors: [Author.Item]
            let tags: [Tag.Item]
        }

        struct Post {

            struct List {
                let posts: [Post.Item]
                let pagination: [Pagination]
            }

            struct Detail {
                let post: Post.Item

                let related: [Post.Item]
                let moreByAuthor: [Post.Item]

                let next: Post.Item?
                let prev: Post.Item?
            }

            struct Item {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                let date: String
                
                let tags: [Tag.Item]
                let authors: [Author.Item]
                let readingTime: Int
                let featured: Bool
            }
        }

        struct Author {
            
            struct List {
                let authors: [Author.Item]
            }

            struct Detail {
                let author: Author.Item
                let posts: [Post.Item]
            }
            
            struct Item {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                
                let numberOfPosts: Int
            }
        }

        struct Tag {
            
            struct List {
                let tags: [Tag.Item]
            }

            struct Detail {
                let tag: Tag.Item
                let posts: [Post.Item]
            }

            
            struct Item {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                
                let numberOfPosts: Int
            }
        }
    }
}

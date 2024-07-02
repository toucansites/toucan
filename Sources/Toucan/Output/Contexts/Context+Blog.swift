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

                let related: [Post.Reference]
                let moreByAuthor: [Post.Reference]

                let next: Post.Reference?
                let prev: Post.Reference?
            }

            struct Item {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                
                let readingTime: Int
                let featured: Bool
                let date: String
                let tags: [Tag.Reference]
                let authors: [Author.Reference]
            }
            
            struct Reference {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                
                let readingTime: Int
                let featured: Bool
                let date: String
            }
        }

        struct Author {
            
            struct List {
                let authors: [Author.Item]
            }

            struct Detail {
                let author: Author.Item
                let posts: [Post.Reference]
            }
            
            struct Item {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                
                let numberOfPosts: Int
            }
            
            struct Reference {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
            }
        }

        struct Tag {
            
            struct List {
                let tags: [Tag.Item]
            }

            struct Detail {
                let tag: Tag.Item
                let posts: [Post.Reference]
            }

            
            struct Item {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                
                let numberOfPosts: Int
            }
            
            struct Reference {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
            }
        }
    }
}

//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Context {
    
    struct Blog {

        struct HomePage {
            let featured: [Post.Item]
            let posts: [Post.Item]
            let authors: [Author.Item]
            let tags: [Tag.Item]
        }

        struct Post {

            struct ListPage {
                let posts: [Post.Item]
                let pagination: [Pagination]
            }

            struct DetailPage {
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
            
            struct ListPage {
                let authors: [Author.Item]
            }

            struct DetailPage {
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
            
            struct Reference {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
            }
        }

        struct Tag {
            
            struct ListPage {
                let tags: [Tag.Item]
            }

            struct DetailPage {
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

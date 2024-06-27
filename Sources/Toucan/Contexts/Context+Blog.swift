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

            let slug: String
            let permalink: String
            let title: String
            let description: String
            let imageUrl: String?
            let date: String

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
            
            let slug: String
            let permalink: String
            let title: String
            let description: String
            let imageUrl: String?
            
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

            
            let slug: String
            let permalink: String
            let title: String
            let description: String
            let imageUrl: String?

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
    
    // TODO: move
    struct Docs {
        
        struct Category {
            
            struct List {
                let categories: [Category]
            }
            
            struct Detail {
                let category: Category
                let guides: [Guide]
            }
            
            
            let title: String
            
        }
        
        struct Guide {
            
            struct List {
                let guides: [Guide]
            }
            
            struct Detail {
                let guide: Guide
            }

            let title: String
        }

        struct Home {
            let categories: [Category]
            let guides: [Guide]
        }
    }
}

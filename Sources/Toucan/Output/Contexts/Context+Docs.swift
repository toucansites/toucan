//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Context {
    
    struct Docs {
                
        struct HomePage {
            let categories: [Category.Item]
            let guides: [Guide.Reference]
        }

        struct Category {
            
            struct ListPage {
                let categories: [Category.Item]
            }
            
            struct DetailPage {
                let categories: [Category.Item]
                let category: Category.Item
            }

            struct Item {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                let date: String
                
                let guides: [Guide.Reference]
                let userDefined: [String: Any]
            }
            
            struct Reference {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                let date: String
            }
        }
        
        struct Guide {
            
            struct ListPage {
                let categories: [Category.Item]
                let guides: [Guide.Reference]
            }
            
            struct DetailPage {
                let categories: [Category.Item]
                let guide: Guide.Item
            }
            
            struct Item {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                let date: String

                let category: Category.Reference
                let userDefined: [String: Any]
                let prev: Guide.Reference?
                let next: Guide.Reference?
            }
            
            struct Reference {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                let date: String
            }
        }
    }
}


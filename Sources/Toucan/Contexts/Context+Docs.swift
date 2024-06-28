//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Context {
    
    struct Docs {
        
        struct Home {
            let categories: [Category.Link]
            let guides: [Guide.Link]
        }

        struct Category {
            
            struct List {
                let categories: [Category.Link]
            }
            
            struct Detail {
                let category: Category.Item
                let guides: [Guide.Link]
            }
            
            struct Item {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                let date: String
                
                let guides: [Guide.Link]
                let userDefined: [String: Any]
            }
            
            struct Link {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                let date: String
                
                let guides: [Guide.Link]
            }
        }
        
        struct Guide {
            
            struct List {
                let guides: [Guide.Link]
            }
            
            struct Detail {
                let categories: [Category.Link]
                let guide: Guide.Item
            }
            
            struct Item {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
                let date: String

                let category: Category.Link
                let userDefined: [String: Any]
            }
            
            struct Link {
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


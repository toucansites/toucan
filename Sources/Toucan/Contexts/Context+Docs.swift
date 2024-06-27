//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

extension Context {
    
    struct Docs {
        
        struct Home {
            let categories: [Category]
            let guides: [Guide]
        }

        struct Category {
            
            struct List {
                let categories: [Category]
            }
            
            struct Detail {
                let category: Category
                let guides: [Guide]
            }
            
            
            let slug: String
            let permalink: String
            let title: String
            let description: String
            let imageUrl: String?
            let date: String

            let guides: [Guide]
            let userDefined: [String: Any]
        }
        
        struct Guide {
            
            struct List {
                let guides: [Guide]
            }
            
            struct Detail {
                let guide: Guide
            }

            let slug: String
            let permalink: String
            let title: String
            let description: String
            let imageUrl: String?
            let date: String

            let category: Category
            let readingTime: Int
            let userDefined: [String: Any]
        }
    }
}


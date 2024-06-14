//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/05/2024.
//

extension Site.State {
    
    struct Figure {
        let src: String
        let darkSrc: String?
        let alt: String?
        let title: String?
    }
    
    struct Pagination {
        let number: Int
        let total: Int

        let slug: String
        let permalink: String
        let isCurrent: Bool
    }
    
    struct HTML<T> {

        struct Site {
            let baseUrl: String
            let title: String
            let description: String
            let language: String?
        }

        struct Page<C> {

            struct Metadata {
                let slug: String
                let permalink: String
                let title: String
                let description: String
                let imageUrl: String?
            }

            let metadata: Metadata
            let context: C
            let content: String
        }
        
        let site: Site
        let page: Page<T>
        let userDefined: [String: Any]
        let year: Int
    }
}

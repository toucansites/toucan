//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/06/2024.
//

struct Context {

    struct Site {
        let baseUrl: String
        let title: String
        let description: String
        let language: String?
    }

    struct Metadata {
        let slug: String
        let permalink: String
        let title: String
        let description: String
        let imageUrl: String?
    }

    struct Pagination {
        let number: Int
        let total: Int

        let slug: String
        let permalink: String
        let isCurrent: Bool
    }
    
    struct Figure {
        let src: String
        let darkSrc: String?
        let alt: String?
        let title: String?
    }

    
//    let main: Main
//    let blog: Blog
//    //let docs: Docs
//    let pages: Pages
}

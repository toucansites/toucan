//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/05/2024.
//

struct Context {

    struct Site {
        let baseUrl: String
        let title: String
        let description: String
        let language: String?
        let context: [String: Any]?
    }

    struct Metadata {
        struct Hreflang {
            let lang: String
            let url: String
        }

        let slug: String
        let permalink: String
        let title: String
        let description: String
        let imageUrl: String?
        let noindex: Bool
        let canonical: String
        let hreflang: [Hreflang]?
        let prev: String?
        let next: String?
    }

    struct Pagination {
        let number: Int
        let total: Int

        let slug: String
        let permalink: String
        let isCurrent: Bool
    }
}


struct HTML: Output {

//    struct Page {
//        let metadata: Context.Metadata
//        let css: [String]
//        let js: [String]
//        let data: [Any]
//        let context: Any
//        let content: String
//        let toc: [ToCTree]
//    }

    let site: Context.Site
    let page: PageBundle
    let context: [String: Any]
    let year: Int
}

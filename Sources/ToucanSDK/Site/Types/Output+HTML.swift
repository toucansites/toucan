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

    //    struct Pagination {
    //        let number: Int
    //        let total: Int
    //
    //        let slug: String
    //        let permalink: String
    //        let isCurrent: Bool
    //    }
}

struct HTML: Output {

    let site: Context.Site
    let page: [String: Any]
    let userDefined: [String: Any]
    let data: [[String: Any]]
    let year: Int
}

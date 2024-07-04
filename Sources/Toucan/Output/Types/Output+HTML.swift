//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/05/2024.
//

struct HTML<T>: Output {

    struct Page<C> {
        let metadata: Context.Metadata
        let css: [String]
        let js: [String]
        let data: [Any]
        let context: C
        let content: String
        let toc: [ToCTree]
    }

    let site: Context.Site
    let page: Page<T>
    let userDefined: [String: Any]
    let year: Int
}

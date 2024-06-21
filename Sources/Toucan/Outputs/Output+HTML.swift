//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/05/2024.
//

extension Output {

    struct HTML<T> {
        struct Page<C> {
            let metadata: Context.Metadata
            let context: C
            let content: String
        }

        let site: Context.Site
        let page: Page<T>
        let userDefined: [String: Any]
        let year: Int
    }
}

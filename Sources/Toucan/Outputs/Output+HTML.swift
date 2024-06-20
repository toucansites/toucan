//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/05/2024.
//

extension Output {

    struct HTML<T> {
        struct Page<C> {
            let metadata: State.Metadata
            let context: C
            let content: String
        }

        let site: State.Site
        let page: Page<T>
        let userDefined: [String: Any]
        let year: Int
    }
}

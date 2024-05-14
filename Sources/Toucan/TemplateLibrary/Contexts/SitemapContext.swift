//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/05/2024.
//

struct SitemapContext {

    struct URL {
        let location: String
        let lastModification: String
    }

    let urls: ArrayContext<URL>
}

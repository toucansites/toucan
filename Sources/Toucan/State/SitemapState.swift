//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/05/2024.
//

struct SitemapState {

    struct URLState {
        let location: String
        let lastModification: String
    }

    let urls: [URLState]
}

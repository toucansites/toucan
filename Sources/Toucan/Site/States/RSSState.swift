//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/05/2024.
//

struct RSSState {

    struct ItemState {
        let permalink: String
        let title: String
        let description: String
        let publicationDate: String
    }

    let title: String
    let description: String
    let baseUrl: String
    let language: String?
    let lastBuildDate: String
    let publicationDate: String
    let items: [ItemState]
}

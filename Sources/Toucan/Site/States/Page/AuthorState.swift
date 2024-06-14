//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/05/2024.
//

struct AuthorState {
    let permalink: String
    let title: String
    let description: String
    let figure: Site.State.Figure?
    let numberOfPosts: Int
    let userDefined: [String: Any]
    let markdown: String
}

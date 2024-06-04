//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 21/05/2024.
//

struct PostState {
    let permalink: String
    let title: String
    let excerpt: String
    let date: String
    let figure: FigureState?

    let tags: [TagState]
    let authors: [AuthorState]
    let readingTime: Int
    let featured: Bool
}

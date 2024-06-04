//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 21/05/2024.
//

struct PostDetailState {
    let post: PostState
    
    let related: [PostState]
    let moreByAuthor: [PostState]

    let next: PostState?
    let prev: PostState?    
}

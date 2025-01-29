//
//  contenttype.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

struct ContentType {

    let id: String
    let location: String?

    let properties: [Property]
    let relations: [Relation]
    let queries: [String: Query]
}

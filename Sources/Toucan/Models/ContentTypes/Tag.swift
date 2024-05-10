//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation

struct Tag: ContentType {
    let id: String
    let slug: String
    let metatags: Metatags
    let publication: Date
    let lastModification: Date
    let variables: [String: String]
    let markdown: String
}

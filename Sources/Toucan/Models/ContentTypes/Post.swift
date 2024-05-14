//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation

struct Post: ContentType {
    let id: String
    let slug: String
    let meta: Meta
    let lastModification: Date
    let frontMatter: [String: String]
    let markdown: String

    let publication: Date
    let authorIds: [String]
    let tagIds: [String]
}

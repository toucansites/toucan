//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation

struct Tag: Content {
    let id: String
    let slug: String
    let meta: Meta
    let lastModification: Date
    let frontMatter: [String: String]
    let markdown: String
}

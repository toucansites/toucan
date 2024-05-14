//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation

struct Author: ContentType {
    let id: String
    let slug: String
    let meta: Meta
    let publication: Date
    let lastModification: Date
    let variables: [String: String]
    let markdown: String
}

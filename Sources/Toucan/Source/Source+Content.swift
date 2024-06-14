//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation

extension Source {

    struct Content {
        let slug: String
        let title: String
        let description: String
        let coverImage: String?
        let template: String?

        let lastModification: Date
        let frontMatter: [String: Any]
        let markdown: String
    }
}

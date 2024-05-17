//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/05/2024.
//

import Foundation

protocol Content {
        
    var id: String { get }
    var slug: String { get }
    var meta: Meta { get }
    var lastModification: Date { get }
    var frontMatter: [String: String] { get }
    var markdown: String { get }
}

enum ContentType: String, CaseIterable {
    case post
    case tag
    case author
    case page
}

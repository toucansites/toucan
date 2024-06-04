//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/05/2024.
//

import struct Foundation.Date

protocol ContentInterface {
    
    static var folder: String { get }
    static var slugPrefix: String? { get }
    
    var id: String { get }
    var slug: String { get }
    var title: String { get }
    var description: String { get }
    var coverImage: String? { get }
    var template: String? { get }
    var lastModification: Date { get }
    var frontMatter: [String: Any] { get }
    var markdown: String { get }

    var userDefined: [String: Any] { get }
}


extension ContentInterface {
        
    var template: String? {
        guard
            let template = frontMatter["template"] as? String,
            !template.isEmpty
        else {
            return nil
        }
        return template
    }
}

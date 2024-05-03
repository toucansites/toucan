//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Markdown

public struct HTMLRenderer {
    
    public init() {
        
    }
    
    public func render(markdown: String) -> String {
        let document = Document(parsing: markdown)
        var htmlVisitor = HTMLVisitor()
        return htmlVisitor.visitDocument(document)
    }
}



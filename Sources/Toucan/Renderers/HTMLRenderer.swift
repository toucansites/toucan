//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Markdown

extension HTMLRenderer.Delegate {

    func imageOverride(_ image: Image) -> String? {
        nil
    }

    func linkAttributes(_ link: String?) -> [String: String] {
        [:]
    }
}

/// A HTML renderer for Markdown documents.
public struct HTMLRenderer {
    
    public protocol Delegate {
        func imageOverride(_ image: Image) -> String?
        func linkAttributes(_ link: String?) -> [String: String]
    }
    
    let delegate: Delegate?

    /// Public init.
    public init(delegate: Delegate? = nil) {
        self.delegate = delegate
    }
    
    /// Render a Markdown string.
    public func render(
        markdown: String
    ) -> String {
        let document = Document(parsing: markdown)
        var htmlVisitor = HTMLVisitor(delegate: delegate)
        
        return htmlVisitor.visitDocument(document)
    }
}

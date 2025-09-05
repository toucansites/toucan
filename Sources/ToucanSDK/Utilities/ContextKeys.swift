//
//  ContextKeys.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 09. 04..
//

/// Root-level keys used in the rendered context bundles.
public enum RootContextKeys: String, CaseIterable {
    case page
    case iterator
    case context
}

/// Standard keys included in the page context dictionary.
public enum PageContextKeys: String, CaseIterable {
    case contents
    case permalink
}

/// Keys for the `page.contents` dictionary.
public enum PageContentsKeys: String, CaseIterable {
    case html
    case readingTime
    case outline
}

/// Keys for iterator metadata inside the context bundle.
public enum IteratorKeys: String, CaseIterable {
    case total
    case limit
    case current
    case items
    case links
}

/// Global keys merged into the rendering context.
public enum GlobalContextKeys: String, CaseIterable {
    case baseUrl
    case generator
    case generation
    case site
}

/// Front matter keys related to view resolution.
public enum ViewFrontMatterKeys: String, CaseIterable {
    case view
    case views
    case any = "views.*"
}

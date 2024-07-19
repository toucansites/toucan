//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation

struct SourceLoader {

    let sourceUrl: URL
    let fileManager: FileManager
    let frontMatterParser: FrontMatterParser

    /// load the configuration & the contents of the site source
    func load() throws -> Source {

        let configLoader = ConfigLoader(
            sourceUrl: sourceUrl,
            fileManager: fileManager
        )
        let config = try configLoader.load()
        
        let contentTypeLoader = ContentTypeLoader(
            sourceUrl: sourceUrl,
            config: config,
            fileManager: fileManager
        )
        let contentTypes = try contentTypeLoader.load()

        let pageBundleLoader = PageBundleLoader(
            sourceUrl: sourceUrl,
            config: config,
            contentTypes: contentTypes,
            fileManager: fileManager,
            frontMatterParser: frontMatterParser
        )
        let pageBundles = try pageBundleLoader.load()

        return .init(
            url: sourceUrl,
            config: config,
            contentTypes: contentTypes,
            pageBundles: pageBundles
        )
    }
}

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
    func load() throws {

        let configLoader = ConfigLoader(
            sourceUrl: sourceUrl,
            fileManager: fileManager
        )

        let config = try configLoader.load()

        let pageBundleLoader = PageBundleLoader(
            sourceUrl: sourceUrl,
            config: config,
            fileManager: fileManager,
            frontMatterParser: frontMatterParser
        )
        let pageBundles = try pageBundleLoader.load()

//        return .init(
//            config: config,
//            materials: materials
//        )
    }
}

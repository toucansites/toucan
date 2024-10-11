//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation
import Logging

struct SourceLoader {

    let baseUrl: String?
    let sourceUrl: URL
    let fileManager: FileManager
    let frontMatterParser: FrontMatterParser
    let logger: Logger

    /// load the configuration & the contents of the site source
    func load() throws -> Source {

        let configLoader = ConfigLoader(
            sourceUrl: sourceUrl,
            fileManager: fileManager,
            baseUrl: baseUrl,
            logger: logger
        )
        let config = try configLoader.load()

        let contentTypeLoader = ContentTypeLoader(
            sourceUrl: sourceUrl,
            config: config,
            fileLoader: .yaml,
            yamlParser: .init(),
            logger: logger
        )
        let contentTypes = try contentTypeLoader.load()

        let pageBundleLoader = PageBundleLoader(
            sourceUrl: sourceUrl,
            config: config,
            contentTypes: contentTypes,
            fileManager: fileManager,
            frontMatterParser: frontMatterParser,
            logger: logger
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

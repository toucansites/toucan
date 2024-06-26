//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation

struct Source {

    let config: Config
    let contents: Materials
}

extension Source {

    struct Loader {

        let configUrl: URL
        let contentsUrl: URL
        let fileManager: FileManager
        let frontMatterParser: FrontMatterParser

        /// load the configuration & the contents of the site source
        func load() async throws -> Source {

            let configLoader = ConfigLoader(
                configFileUrl: configUrl,
                fileManager: fileManager,
                frontMatterParser: frontMatterParser
            )

            let config = try configLoader.load()

            let contentsLoader = MaterialsLoader(
                contentsUrl: contentsUrl,
                config: config,
                fileManager: fileManager,
                frontMatterParser: frontMatterParser
            )
            let contents = try contentsLoader.load()

            return .init(
                config: config,
                contents: contents
            )
        }
    }
}

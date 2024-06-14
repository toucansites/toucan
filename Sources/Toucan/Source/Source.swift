//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation

struct Source {

    let config: Config
    let contents: Contents

    struct Loader {
        let url: URL

        /// load the configuration & the contents of the site source
        func load() async throws -> Source {

            let fileManager = FileManager.default
            let frontMatterParser = FrontMatterParser()

            let configLoader = ConfigLoader(
                configFileUrl: url.appendingPathComponent("config.yaml"),
                fileManager: fileManager,
                frontMatterParser: frontMatterParser
            )

            let config = try configLoader.load()

            let contentsLoader = ContentsLoader(
                contentsUrl: url.appendingPathComponent("contents"),
                configuration: config,
                fileManager: fileManager,
                frontMatterParser: frontMatterParser
            )
            let contents = try await contentsLoader.load()

            return .init(
                config: config,
                contents: contents
            )
        }
    }
}

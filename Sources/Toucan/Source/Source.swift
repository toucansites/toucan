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
    let assets: Assets   
}

extension Source {

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
                config: config,
                fileManager: fileManager,
                frontMatterParser: frontMatterParser
            )
            let contents = try contentsLoader.load()
            
            let assetsLoader = AssetsLoader(
                config: config,
                contents: contents,
                fileManager: fileManager
            )
            
            let assets = try assetsLoader.load()

            return .init(
                config: config,
                contents: contents,
                assets: assets
            )
        }
    }
}

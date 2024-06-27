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
    func load() async throws -> Source {

        let configLoader = SourceConfigLoader(
            sourceUrl: sourceUrl,
            fileManager: fileManager,
            frontMatterParser: frontMatterParser
        )

        let config = try configLoader.load()

        let materialsLoader = SourceMaterialLoader(
            config: config,
            fileManager: fileManager,
            frontMatterParser: frontMatterParser
        )
        let materials = try materialsLoader.load()

        return .init(
            config: config,
            materials: materials
        )
    }
}

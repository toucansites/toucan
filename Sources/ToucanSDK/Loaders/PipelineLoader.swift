//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 01..
//

import Foundation
import Logging
import ToucanFileSystem
import ToucanModels
import Yams

struct PipelineLoader {

    let url: URL

    let locations: [String]

    let yamlParser: YamlParser
    let logger: Logger

    func load() throws -> [Pipeline] {
        var items: [Pipeline] = []
        for location in locations {
            let item = try resolveItem(location)
            items.append(item)
        }

        let list = items.map(\.engine.id).joined(separator: ", ")
        logger.debug("Available pipelines: `\(list)`.")

        return items
    }
}

private extension PipelineLoader {

    func resolveItem(_ location: String) throws -> Pipeline {
        let url = url.appendingPathComponent(location)
        return try loadItem(at: url)
    }

    func loadItem(at url: URL) throws -> Pipeline {
        let string = try String(contentsOf: url, encoding: .utf8)
        return try yamlParser.decode(string, as: Pipeline.self)
    }
}

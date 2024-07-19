//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 19/07/2024.
//

import Foundation
import FileManagerKit
import Yams

struct ContentTypeLoader {
    
    /// An enumeration representing possible errors that can occur while loading the configuration.
    enum Error: Swift.Error {
        case missing
        /// Indicates an error related to file operations.
        case file(Swift.Error)
        /// Indicates an error related to parsing YAML.
        case yaml(YamlError)
    }
    
    /// The URL of the source files.
    let sourceUrl: URL
    
    let config: Config
    /// The file manager used for file operations.
    let fileManager: FileManager
    
    
    func load() throws -> [ContentType] {
        let typesUrl = sourceUrl.appendingPathComponent(config.types.folder)
        let list = fileManager.listDirectory(at: typesUrl)
            .filter { $0.hasSuffix(".yml") }
        
        var types: [ContentType] = []
        var hasPageOverride = false
        for file in list {
            let decoder = YAMLDecoder()
            let data = try Data(contentsOf: typesUrl.appendingPathComponent(file))
            let type = try decoder.decode(ContentType.self, from: data)
            types.append(type)
            if type.id == "page" {
                hasPageOverride = true
            }
        }
        /// add default page type if needed
        if !hasPageOverride {
            types.append(
                .init(
                    id: "page",
                    context: .init(
                        site: [
                            "pages": .init(
                                sort: "title",
                                order: .asc,
                                pagination: .init(limit: 10)
                            )
                        ],
                        page: [:],
                        relations: [:]
                    ),
                    template: "pages.single.page",
                    properties: [
                        "TODO"
                    ]
                )
            )
        }

        return types
    }
}

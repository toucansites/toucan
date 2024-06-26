//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/06/2024.
//

import Foundation
import FileManagerKit

extension Source {

    struct AssetsLoader {

        enum Error: Swift.Error {
            case asset(Swift.Error)
        }

        let config: Config
        let contents: Contents

        let fileManager: FileManager

        func load(to destination: URL) throws -> Assets {

            for content in contents.all() {
                let assetsUrl = content.location
                    .appendingPathComponent(content.assetsFolder)
                
                guard
                    fileManager.directoryExists(at: assetsUrl),
                    !fileManager.listDirectory(at: assetsUrl).isEmpty
                else {
                    continue
                }
                
                let outputUrl = destination
                    .appendingPathComponent(content.slug)

                try fileManager.copyRecursively(
                    from: assetsUrl,
                    to: outputUrl
                )
            }

            return .init(
                storage: [:]
            )
        }
    }
}

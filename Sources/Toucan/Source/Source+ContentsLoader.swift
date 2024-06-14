//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation
import FileManagerKit

extension Source {

    struct ContentsLoader {

        let contentsUrl: URL
        let configuration: Config
        let fileManager: FileManager
        let frontMatterParser: FrontMatterParser

        // MARK: - private

        private func getMarkdownURLs(
            at url: URL
        ) -> [URL] {
            var toProcess: [URL] = []
            let dirEnum = fileManager.enumerator(atPath: url.path)
            while let file = dirEnum?.nextObject() as? String {
                let url = url.appendingPathComponent(file)
                guard url.pathExtension.lowercased() == "md" else {
                    continue
                }
                toProcess.append(url)
            }
            return toProcess
        }

        func load() async throws -> Contents {
            fatalError()
        }

    }
}

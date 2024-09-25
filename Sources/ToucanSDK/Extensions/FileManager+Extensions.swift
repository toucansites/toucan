//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/05/2024.
//

import Foundation

extension FileManager {

    func createParentFolderIfNeeded(for url: URL) throws {
        let folderPath =
            "/"
            + url
            .pathComponents
            .dropLast()
            .joined(separator: "/")

        try createDirectory(
            at: .init(
                fileURLWithPath: folderPath
            )
        )
    }

    func getURLs(
        at url: URL,
        for extensions: [String]
    ) -> [URL] {
        var result: [URL] = []
        let dirEnum = enumerator(atPath: url.path)
        while let file = dirEnum?.nextObject() as? String {
            let url = url.appendingPathComponent(file)
            let ext = url.pathExtension.lowercased()
            guard extensions.contains(ext) else {
                continue
            }
            result.append(url)
        }
        return result
    }

    func recursivelyListDirectory(
        at url: URL
    ) -> [String] {
        var result: [String] = []
        let dirEnum = enumerator(atPath: url.path)
        while let file = dirEnum?.nextObject() as? String {
            result.append(file)
        }
        return result
    }
}

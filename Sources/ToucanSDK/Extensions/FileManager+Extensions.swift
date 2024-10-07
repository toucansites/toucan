//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/05/2024.
//

import Foundation

extension FileManager {

    func copyRecursively(
        from inputURL: URL,
        to outputURL: URL
    ) throws {
        guard directoryExists(at: inputURL) else {
            return
        }
        if !directoryExists(at: outputURL) {
            try createDirectory(at: outputURL)
        }

        for item in listDirectory(at: inputURL) {
            let itemSourceUrl = inputURL.appendingPathComponent(item)
            let itemDestinationUrl = outputURL.appendingPathComponent(item)
            if fileExists(at: itemSourceUrl) {
                if fileExists(at: itemDestinationUrl) {
                    try delete(at: itemDestinationUrl)
                }
                try copy(from: itemSourceUrl, to: itemDestinationUrl)
            }
            else {
                try copyRecursively(from: itemSourceUrl, to: itemDestinationUrl)
            }
        }
    }

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

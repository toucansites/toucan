//
//  FileManagerKit+Extensions.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 10..
//

import FileManagerKit
import Foundation

public extension FileManagerKit {

    func listDirectoryRecursively(at url: URL) -> [URL] {
        listDirectory(at: url)
            .reduce(into: [URL]()) { result, path in
                let itemUrl = url.appendingPathComponent(path)

                if directoryExists(at: itemUrl) {
                    result += listDirectoryRecursively(at: itemUrl)
                }
                else {
                    result.append(itemUrl)
                }
            }
    }
    
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
    
}

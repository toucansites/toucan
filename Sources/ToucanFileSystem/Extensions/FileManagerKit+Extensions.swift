//
//  FileManagerKit+Extensions.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 10..
//

import FileManagerKit
import Foundation

extension FileManagerKit {
    
    func listDirectoryRecursively(at url: URL) -> [URL] {
        listDirectory(at: url)
            .reduce(into: [URL]()) { result, path in
                let itemUrl = url.appendingPathComponent(path)
                
                if directoryExists(at: itemUrl) {
                    result += listDirectoryRecursively(at: itemUrl)
                } else {
                    result.append(itemUrl)
                }
            }
    }
}

//
//  URL+Extensions.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 10..
//

import Foundation

extension URL {
    
    public func relativePath(to url: URL) -> String {
        guard
            let fullPath = URLComponents(url: self, resolvingAgainstBaseURL: true)?.path,
            let basePath = URLComponents(url: url, resolvingAgainstBaseURL: true)?.path
        else {
            return self.path
        }
        
        if fullPath.hasPrefix(basePath) {
            return String(fullPath.dropFirst(basePath.count))
        }
        
        return fullPath
    }
}

extension [URL] {
    
    func relativePathsGroupedByPathId(baseUrl: URL) -> [String: String] {
        Dictionary(uniqueKeysWithValues: map { url in
            let relativePath = url.relativePath(to: baseUrl)
            let id = relativePath.pathIdValue
            return (id, relativePath)
        })
    }
}

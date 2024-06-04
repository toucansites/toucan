//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 27/05/2024.
//

import Foundation

extension FileManager {

    func createParentFolderIfNeeded(for url: URL) throws {
        let folderPath = "/" + url
            .pathComponents
            .dropLast()
            .joined(separator: "/")
        
        try createDirectory(
            at: .init(
                fileURLWithPath: folderPath
            )
        )
    }
}

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
        
        func load() throws -> Assets {
            .init(storage: [:])
        }
    }
}

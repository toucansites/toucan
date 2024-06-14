//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 14/06/2024.
//

import Foundation

extension Source {
    
    struct Assets {
        
        enum Variant {
            case light
            case dark
        }
        
        /// key value dictionary where the key is the asset reference and the value is the path of the asset file
        let storage: [String: String]

        func url(
            for value: String?,
            folder: String,
            variant: Variant = .light,
            permalink: (String) -> String
        ) -> String? {
            guard let value, !value.isEmpty else {
                return nil
            }
            /// it is not a local reference, return it as it is
            guard value.hasPrefix("./") else {
                return value
            }
            var key: String
            switch variant {
            case .light:
                key = value
            case .dark:
                var items = value.split(separator: ".")
                items.insert("~dark", at: items.count - 1)
                key = items
                    .joined(separator: ".")
                    .replacingOccurrences(of: ".~dark", with: "~dark")
            }
            
            key = key.replacingOccurrences(
                of: "./",
                with: "./\(folder)/"
            )
            
            if let newPath = storage[key] {
                return permalink(newPath)
            }
            return nil
        }
    }
}

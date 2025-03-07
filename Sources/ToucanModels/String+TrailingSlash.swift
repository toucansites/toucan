//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 07..
//

import Foundation

extension String {
    
    func dropTrailingSlash() -> String {
        if hasSuffix("/") {
            return String(dropLast())
        }
        return self
    }
}

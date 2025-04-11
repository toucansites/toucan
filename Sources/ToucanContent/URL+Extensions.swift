//
//  String+Extensions.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 12..
//

import Foundation

public extension URL {

    func loadDataAsString() throws -> String {
        return try String(contentsOf: self, encoding: .utf8)
    }

}

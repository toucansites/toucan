//
//  URL+Extensions.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 12..
//

import Foundation

public extension URL {

    func loadContents(
        using encoding: String.Encoding = .utf8
    ) throws -> String {
        try String(contentsOf: self, encoding: encoding)
    }
}

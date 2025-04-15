//
//  String+Extensions.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 12..
//

import Foundation

public extension String {

    func dataValue(using encoding: String.Encoding = .utf8) -> Data {
        data(using: encoding)!
    }

    func dropTrailingSlash() -> String {
        if hasSuffix("/") {
            return String(dropLast())
        }
        return self
    }

}

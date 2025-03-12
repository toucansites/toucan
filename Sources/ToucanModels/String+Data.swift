//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 12..
//

import Foundation

public extension String {

    func dataValue() -> Data {
        data(using: .utf8)!
    }
}

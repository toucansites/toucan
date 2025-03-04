//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 04..
//

import Foundation

public struct ReservedFrontMatter: Decodable {

    public let type: String?

    public static func empty() -> Self {
        .init(type: nil)
    }

    public init(type: String?) {
        self.type = type
    }
}

extension ReservedFrontMatter: Equatable {

}

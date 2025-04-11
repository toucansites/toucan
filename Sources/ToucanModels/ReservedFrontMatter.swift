//
//  ReservedFrontMatter.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 04..
//

import Foundation

public struct ReservedFrontMatter: Decodable, Equatable {

    public let type: String?
    //public let assetProperties: [AssetProperty]?

    public static func empty() -> Self {
        .init(type: nil)
    }

    public init(type: String?) {
        self.type = type
        //self.assetProperties = nil
    }
}

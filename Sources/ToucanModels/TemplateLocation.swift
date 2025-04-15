//
//  OverrideFileLocation.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation

public struct TemplateLocation: Equatable {

    public let id: String
    public let path: String

    public init(id: String, path: String) {
        self.id = id
        self.path = path
    }
}

//
//  OverrideFileLocation.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

public struct OverrideFileLocation: Equatable {

    public let path: String
    public let overridePath: String?

    public init(path: String, overridePath: String? = nil) {
        self.path = path
        self.overridePath = overridePath
    }
}

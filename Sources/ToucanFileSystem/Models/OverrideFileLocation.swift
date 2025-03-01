//
//  OverrideFileLocation.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

public struct OverrideFileLocation: Equatable, Comparable {

    public static func < (
        lhs: OverrideFileLocation,
        rhs: OverrideFileLocation
    ) -> Bool {
        lhs.path < rhs.path
    }

    public let path: String
    public let overridePath: String?

    public init(path: String, overridePath: String? = nil) {
        self.path = path
        self.overridePath = overridePath
    }
}

//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 22/07/2024.
//

import Foundation

public struct ToC {
    public let level: Int
    public let text: String
    public let fragment: String
    public var children: [ToC]

    public init(
        level: Int,
        text: String,
        fragment: String,
        children: [ToC] = []
    ) {
        self.level = level
        self.text = text
        self.fragment = fragment
        self.children = children
    }
}

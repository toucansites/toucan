//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 22/07/2024.
//

public struct ToC {

    public var level: Int

    public var text: String

    public var fragment: String?

    public var children: [ToC]

    public init(
        level: Int,
        text: String,
        fragment: String? = nil,
        children: [ToC] = []
    ) {
        self.level = level
        self.text = text
        self.fragment = fragment
        self.children = children
    }
}

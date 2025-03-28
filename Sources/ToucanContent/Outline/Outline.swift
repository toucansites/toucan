//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 22/07/2024.
//

public struct Outline: Equatable, Codable {

    public var level: Int

    public var text: String

    public var fragment: String?

    public var children: [Outline]

    public init(
        level: Int,
        text: String,
        fragment: String? = nil,
        children: [Outline] = []
    ) {
        self.level = level
        self.text = text
        self.fragment = fragment
        self.children = children
    }
}

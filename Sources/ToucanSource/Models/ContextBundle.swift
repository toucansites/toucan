//
//  ContextBundle.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

import ToucanModels

public struct ContextBundle {
    public var content: Content
    public var context: [String: AnyCodable]
    public var destination: Destination

    public init(
        content: Content,
        context: [String: AnyCodable],
        destination: Destination
    ) {
        self.content = content
        self.context = context
        self.destination = destination
    }
}

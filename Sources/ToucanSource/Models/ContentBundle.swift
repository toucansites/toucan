//
//  contentbundle.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

import ToucanModels

public struct ContentBundle {

    public var definition: ContentDefinition
    public var contents: [Content]

    public init(
        definition: ContentDefinition,
        contents: [Content]
    ) {
        self.definition = definition
        self.contents = contents
    }
}

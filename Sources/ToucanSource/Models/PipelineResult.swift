//
//  PipelineResult.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

public struct PipelineResult {
    public var contents: String
    public var destination: Destination

    public init(
        contents: String,
        destination: Destination
    ) {
        self.contents = contents
        self.destination = destination
    }
}

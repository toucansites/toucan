//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 20..
//

public struct TransformerPipeline {

    // TODO: move commands url here?
    public var commands: [TransformerCommand]

    public init(
        commands: [TransformerCommand]
    ) {
        self.commands = commands
    }
}

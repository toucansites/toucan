//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

import ToucanModels

extension RenderPipeline {

    public struct Engine {
        var id: String
        var options: AnyValue?

        public init(
            id: String,
            options: AnyValue?
        ) {
            self.id = id
            self.options = options
        }
    }
}

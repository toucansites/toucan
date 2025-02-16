//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

import ToucanModels
import ToucanCodable

extension RenderPipeline {

    public struct Engine {
        var id: String
        var options: [String: AnyCodable]

        public init(
            id: String,
            options: [String: AnyCodable]
        ) {
            self.id = id
            self.options = options
        }
    }
}

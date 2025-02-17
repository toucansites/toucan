//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

import ToucanModels

extension RenderPipeline {

    public struct ContentTypes {

        public var filter: [String]
        public var lastUpdate: [String]

        public init(
            filter: [String],
            lastUpdate: [String]
        ) {
            self.filter = filter
            self.lastUpdate = lastUpdate
        }
    }
}

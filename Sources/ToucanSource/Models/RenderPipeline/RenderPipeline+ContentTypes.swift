//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

import ToucanModels

extension RenderPipeline {

    public struct ContentTypes {

        public var include: [String]
        public var exclude: [String]
        public var lastUpdate: [String]

        public init(
            include: [String],
            exclude: [String],
            lastUpdate: [String]
        ) {
            self.include = include
            self.exclude = exclude
            self.lastUpdate = lastUpdate
        }

        public func isAllowed(contentType: String) -> Bool {
            if exclude.contains(contentType) {
                return false
            }
            if include.isEmpty {
                return true
            }
            return include.contains(contentType)
        }
    }
}

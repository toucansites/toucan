//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

extension RenderPipeline.DataTypes {

    public struct Date {

        public var formats: [String: String]

        public init(
            formats: [String: String]
        ) {
            self.formats = formats
        }
    }
}

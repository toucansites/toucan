//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

extension RenderPipeline {

    public struct Output {
        public var path: String
        public var file: String
        public var ext: String

        public init(
            path: String,
            file: String,
            ext: String
        ) {
            self.path = path
            self.file = file
            self.ext = ext
        }
    }
}

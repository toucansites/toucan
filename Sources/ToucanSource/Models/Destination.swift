//
//  Destination.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

public struct Destination {
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

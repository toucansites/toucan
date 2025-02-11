//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 30..
//

public struct RawContent {

    public var origin: Origin
    public var frontMatter: [String: AnyValue]
    public var markdown: String
    public var lastModificationDate: Double
    public var assets: [String]

    public init(
        origin: Origin,
        frontMatter: [String: AnyValue],
        markdown: String,
        lastModificationDate: Double,
        assets: [String]
    ) {
        self.origin = origin
        self.frontMatter = frontMatter
        self.markdown = markdown
        self.lastModificationDate = lastModificationDate
        self.assets = assets
    }
}

//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

public struct TransformerPipeline: Decodable {
    public var run: [ContentTransformer]
    public var isMarkdownResult: Bool

    public init(
        run: [ContentTransformer] = [],
        isMarkdownResult: Bool = true
    ) {
        self.run = run
        self.isMarkdownResult = isMarkdownResult
    }
}

//
//  Pipeline+TransformerPipeline.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 21..
//

/// Represents a sequence of content transformers to run before rendering,
/// along with an indicator of whether the final result is Markdown.
public struct TransformerPipeline: Decodable {

    /// An ordered list of transformers (external commands or scripts) to execute.
    ///
    /// Each `ContentTransformer` represents an individual transformation step.
    public var run: [ContentTransformer]

    /// Indicates whether the final output from this pipeline is expected to be Markdown.
    ///
    /// If `false`, the renderer may treat the output as already-formatted HTML or another format.
    public var isMarkdownResult: Bool

    /// Initializes a new `TransformerPipeline`.
    ///
    /// - Parameters:
    ///   - run: An array of `ContentTransformer` instances to execute.
    ///   - isMarkdownResult: A flag indicating whether the final output is Markdown. Defaults to `true`.
    public init(
        run: [ContentTransformer] = [],
        isMarkdownResult: Bool = true
    ) {
        self.run = run
        self.isMarkdownResult = isMarkdownResult
    }
}

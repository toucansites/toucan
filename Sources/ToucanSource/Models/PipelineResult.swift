//
//  PipelineResult.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

/// Represents the output of a content transformation pipeline, including the
/// transformed content and its intended destination.
public struct PipelineResult {

    /// The final transformed content (e.g., HTML, Markdown, etc.).
    public var contents: String

    /// The destination metadata describing where or how the content should be output.
    public var destination: Destination

    /// Initializes a new `PipelineResult` with transformed content and a destination.
    ///
    /// - Parameters:
    ///   - contents: The transformed content string.
    ///   - destination: A `Destination` indicating where the result should be saved or rendered.
    public init(
        contents: String,
        destination: Destination
    ) {
        self.contents = contents
        self.destination = destination
    }
}

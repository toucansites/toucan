//
//  PipelineResult.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 21..
//

/// Represents the output of a content transformation pipeline, including the
/// transformed content and its intended destination.
public struct PipelineResult: Sendable {
    /// The source material for the pipeline result.
    public enum Source: Sendable {
        /// An asset source, that needs top be copied.
        case assetFile(String)
        /// A generated asset source
        case asset(String)
        /// The final transformed content (e.g., HTML, Markdown, etc.).
        case content(String)

        /// A Boolean value indicating whether the pipeline result's source is content-based.
        /// Returns `true` if the source is `.content`, otherwise `false`.
        public var isContent: Bool {
            !isAsset
        }

        /// A Boolean value indicating whether the pipeline result's source is an asset.
        /// Returns `true` if the source is `.asset`, otherwise `false`.
        public var isAsset: Bool {
            switch self {
            case .content:
                false
            case .assetFile:
                true
            case .asset:
                true
            }
        }
    }

    /// The source material.
    public var source: Source

    /// The destination metadata describing where or how the content should be output.
    public var destination: Destination

    /// Initializes a new `PipelineResult` with transformed content and a destination.
    ///
    /// - Parameters:
    ///   - source: The source material.
    ///   - destination: A `Destination` indicating where the result should be saved or rendered.
    public init(
        source: Source,
        destination: Destination
    ) {
        self.source = source
        self.destination = destination
    }
}

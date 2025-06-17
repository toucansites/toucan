//
//  RawContent.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 30..
//

/// Represents the raw, unprocessed state of a content file, typically sourced from a page bundle.
///
/// Includes both the Markdown body and its front matter metadata, along with file origin and assets.
public struct RawContent: Equatable {
    /// The origin of the content file, including its path and slug.
    public var origin: Origin

    /// The raw Markdown content body.
    public var markdown: Markdown

    /// The last modification timestamp (e.g., from file metadata), in Unix epoch format.
    public var lastModificationDate: Double

    /// The location of the assets folder relative from the origin path.
    public var assetsPath: String

    /// A list of asset paths associated with this content (e.g., images, attachments).
    public var assets: [String]

    /// Initializes a new `RawContent` instance.
    ///
    /// - Parameters:
    ///   - origin: The origin information of the content file.
    ///   - markdown: The contents using the `Markdown` type.
    ///   - lastModificationDate: The file's last modification time (Unix timestamp).
    ///   - assetsPath: The location of the assets folder relative from the origin path.
    ///   - assets: List of asset file paths linked with this content.
    public init(
        origin: Origin,
        markdown: Markdown = .init(),
        lastModificationDate: Double,
        assetsPath: String,
        assets: [String]
    ) {
        self.origin = origin
        self.markdown = markdown
        self.lastModificationDate = lastModificationDate
        self.assetsPath = assetsPath
        self.assets = assets
    }
}

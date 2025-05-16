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

    /// The front matter metadata as a dictionary of key-value pairs.
    ///
    /// These fields are defined at the top of a Markdown file.
    public var frontMatter: [String: AnyCodable]

    /// The raw Markdown content body.
    public var markdown: String

    /// The last modification timestamp (e.g., from file metadata), in Unix epoch format.
    public var lastModificationDate: Double

    /// A list of asset paths associated with this content (e.g., images, attachments).
    public var assets: [String]

    /// Initializes a new `RawContent` instance.
    ///
    /// - Parameters:
    ///   - origin: The origin information of the content file.
    ///   - frontMatter: Metadata fields parsed from the file's front matter.
    ///   - markdown: The body content in raw Markdown format.
    ///   - lastModificationDate: The file's last modification time (Unix timestamp).
    ///   - assets: List of asset file paths linked with this content.
    public init(
        origin: Origin,
        frontMatter: [String: AnyCodable],
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

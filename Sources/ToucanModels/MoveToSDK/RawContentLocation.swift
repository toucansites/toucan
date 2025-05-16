//
//  RawContentLocation.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 31..
//

import Foundation

/// Represents potential file paths for raw content associated with a given slug,
/// such as Markdown and YAML variants.
///
/// Useful in systems where content may be split across different formats or naming conventions.
public struct RawContentLocation: Codable, Equatable {

    /// A unique slug identifier associated with the content.
    public let slug: String

    /// Path to a Markdown file with `.markdown` extension.
    public var markdown: String?

    /// Path to a Markdown file with `.md` extension.
    public var md: String?

    /// Path to a YAML file with `.yaml` extension.
    public var yaml: String?

    /// Path to a YAML file with `.yml` extension.
    public var yml: String?

    /// Indicates whether all content file references are missing (i.e., all paths are nil).
    public var isEmpty: Bool {
        markdown == nil && md == nil && yaml == nil && yml == nil
    }

    /// Initializes a new `RawContentLocation` with optional paths to various content file types.
    ///
    /// - Parameters:
    ///   - slug: The identifier for this content location.
    ///   - markdown: Optional path to a `.markdown` file.
    ///   - md: Optional path to a `.md` file.
    ///   - yaml: Optional path to a `.yaml` file.
    ///   - yml: Optional path to a `.yml` file.
    public init(
        slug: String,
        markdown: String? = nil,
        md: String? = nil,
        yaml: String? = nil,
        yml: String? = nil
    ) {
        self.slug = slug
        self.markdown = markdown
        self.md = md
        self.yaml = yaml
        self.yml = yml
    }
}

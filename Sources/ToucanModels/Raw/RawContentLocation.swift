//
//  RawContentLocation.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 31..
//

import Foundation

public struct RawContentLocation: Codable, Equatable {

    public let slug: String

    public var markdown: String?
    public var md: String?
    public var yaml: String?
    public var yml: String?

    public var isEmpty: Bool {
        markdown == nil && md == nil && yaml == nil && yml == nil
    }

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

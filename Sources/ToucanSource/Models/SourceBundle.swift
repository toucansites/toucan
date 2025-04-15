//
//  SourceBundle.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import ToucanContent
import ToucanModels

public struct SourceBundle {

    public var location: URL
    public var config: Config
    public var sourceConfig: SourceConfig
    public var settings: Settings
    public var pipelines: [Pipeline]
    public var contents: [Content]
    public var blockDirectives: [MarkdownBlockDirective]
    public var templates: [String: String]
    public var baseUrl: String

    public init(
        location: URL,
        config: Config,
        sourceConfig: SourceConfig,
        settings: Settings,
        pipelines: [Pipeline],
        contents: [Content],
        blockDirectives: [MarkdownBlockDirective],
        templates: [String: String],
        baseUrl: String
    ) {
        self.location = location
        self.config = config
        self.sourceConfig = sourceConfig
        self.settings = settings
        self.pipelines = pipelines
        self.contents = contents
        self.blockDirectives = blockDirectives
        self.templates = templates
        self.baseUrl = baseUrl
    }
}

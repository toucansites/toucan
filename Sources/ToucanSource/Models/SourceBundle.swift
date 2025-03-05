//
//  File.swift
//  toucan
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
    public var assets: [String]

    var dateFormatter: DateFormatter

    public init(
        location: URL,
        config: Config,
        sourceConfig: SourceConfig,
        settings: Settings,
        pipelines: [Pipeline],
        contents: [Content],
        blockDirectives: [MarkdownBlockDirective],
        templates: [String: String],
        assets: [String]
    ) {
        self.location = location
        self.config = config
        self.sourceConfig = sourceConfig
        self.settings = settings
        self.pipelines = pipelines
        self.contents = contents
        self.blockDirectives = blockDirectives
        self.templates = templates
        self.assets = assets

        /// setup date formatter
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .init(secondsFromGMT: 0)
        // TODO: validate locale
        if let rawLocale = settings.locale {
            formatter.locale = .init(identifier: rawLocale)
        }
        if let rawTimezone = settings.timeZone,
            let timeZone = TimeZone(identifier: rawTimezone)
        {
            formatter.timeZone = timeZone
        }
        self.dateFormatter = formatter
    }
}

//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import ToucanModels

public struct SourceBundle {

    public var location: URL
    public var config: Config
    public var settings: Settings
    public var renderPipelines: [RenderPipeline]
    public var contentBundles: [ContentBundle]

    public init(
        location: URL,
        config: Config,
        settings: Settings,
        renderPipelines: [RenderPipeline],
        contentBundles: [ContentBundle]
    ) {
        self.location = location
        self.config = config
        self.settings = settings
        self.renderPipelines = renderPipelines
        self.contentBundles = contentBundles
    }

}

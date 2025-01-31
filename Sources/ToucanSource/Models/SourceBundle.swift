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
    public var renderPipelines: [RenderPipeline]
    public var contentBundles: [ContentBundle]

    public init(
        location: URL,
        renderPipelines: [RenderPipeline],
        contentBundles: [ContentBundle]
    ) {
        self.location = location
        self.renderPipelines = renderPipelines
        self.contentBundles = contentBundles
    }

}

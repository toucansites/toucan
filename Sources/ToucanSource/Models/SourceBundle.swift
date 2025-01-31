//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import ToucanModels

public struct SourceBundle {

    public let location: URL
    public let siteBundle: SiteBundle

    public init(
        location: URL,
        siteBundle: SiteBundle
    ) {
        self.location = location
        self.siteBundle = siteBundle
    }

    public func load(
        url: URL
    ) throws -> SourceBundle {

        return .init(
            location: url,
            siteBundle: .init(contentBundles: [])
        )
    }
}

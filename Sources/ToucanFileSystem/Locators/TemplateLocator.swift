//
//  TemplateLocator.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 04..
//

import Foundation
import FileManagerKit
import ToucanModels

public struct TemplateLocator {

    private let fileManager: FileManagerKit

    private let ext = "mustache"

    public init(fileManager: FileManagerKit) {
        self.fileManager = fileManager
    }

    public func locate(at url: URL, overrides: URL) -> [TemplateLocation] {
        locateTemplateLocations(at: url, overrides: overrides)
            .sorted { $0.id < $1.id }
    }
}

private extension TemplateLocator {

    func locateTemplateLocations(
        at url: URL,
        overrides overridesUrl: URL
    ) -> [TemplateLocation] {
        let overrideLocations =
            fileManager
            .listDirectoryRecursively(at: overridesUrl)
            .relativePathsGroupedByPathId(baseUrl: overridesUrl)
            .filter { $1.hasSuffix(".\(ext)") }

        var locations =
            fileManager
            .listDirectoryRecursively(at: url)
            .relativePathsGroupedByPathId(baseUrl: url)
            .filter { $1.hasSuffix(".\(ext)") }

        for (id, url) in overrideLocations {
            if locations[id] != nil {
                locations[id] = url
            }
        }

        return locations.map {
            TemplateLocation(id: $0, path: $1)
        }
    }
}

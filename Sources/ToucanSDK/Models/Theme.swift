//
//  File.swift
//  toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import Foundation
import ToucanSource

/*
 themes
    default
        assets
        templates
    !overrides
        default
            assets
            components
 */
struct Theme {

    struct Components {
        var assets: [String]
        var templates: [Template]
    }

    var name: String
    var location: URL
    var components: Components
    var overrides: Components
}

struct ThemeLoader {

    let locations: BuiltTargetSourceLocations

    init(
        locations: BuiltTargetSourceLocations
    ) {
        self.locations = locations
    }

    func load() throws {

    }
}

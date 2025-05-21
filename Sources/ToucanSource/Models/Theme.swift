//
//  File.swift
//  toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import struct Foundation.URL

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

    var baseUrl: URL
    var components: Components
    var overrides: Components
    var content: Components
}

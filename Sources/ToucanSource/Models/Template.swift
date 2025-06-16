//
//  Template.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import struct Foundation.URL

/**
 Templates directory structure:

 ```
 templates
    default
        assets
        views
    overrides
        default
            assets
            views
 ```
 */

/// Represents a template used by the Toucan system, including paths to assets and templates for both base and override components.
public struct Template {

    /// A group of assets and templates that make up a template component.
    public struct Components {
        /// A list of asset file paths associated with the component.
        public var assets: [String]
        /// A list of templates associated with the component.
        public var views: [View]

        /// Creates a new `Components` instance.
        ///
        /// - Parameters:
        ///   - assets: A list of asset file paths.
        ///   - views: A list of views.
        public init(
            assets: [String],
            views: [View]
        ) {
            self.assets = assets
            self.views = views
        }
    }

    /// The base URL where the template is located.
    public var baseUrl: URL
    /// The primary components of the template.
    public var components: Components
    /// Override components that can replace or augment the default components.
    public var overrides: Components
    /// Content-specific components such as assets and templates used within the template.
    public var content: Components

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - baseUrl: The base URL where the template is located.
    ///   - components: The primary components of the template.
    ///   - overrides: Override components that can replace or augment the default components.
    ///   - content: Content-specific components such as assets and templates used within the template.
    public init(
        baseUrl: URL,
        components: Components,
        overrides: Components,
        content: Components
    ) {
        self.baseUrl = baseUrl
        self.components = components
        self.overrides = overrides
        self.content = content
    }
}

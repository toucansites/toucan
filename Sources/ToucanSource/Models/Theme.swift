//
//  Theme.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import struct Foundation.URL

/**
 Theme directory structure:

 ```
 themes
    default
        assets
        templates
    overrides
        default
            assets
            components
 ```
 */

/// Represents a theme used by the Toucan system, including paths to assets and templates for both base and override components.
public struct Theme {

    /// A group of assets and templates that make up a theme component.
    public struct Components {
        /// A list of asset file paths associated with the component.
        public var assets: [String]
        /// A list of templates associated with the component.
        public var templates: [Template]

        /// Creates a new `Components` instance.
        ///
        /// - Parameters:
        ///   - assets: A list of asset file paths.
        ///   - templates: A list of templates.
        public init(
            assets: [String],
            templates: [Template]
        ) {
            self.assets = assets
            self.templates = templates
        }
    }

    /// The base URL where the theme is located.
    public var baseUrl: URL
    /// The primary components of the theme.
    public var components: Components
    /// Override components that can replace or augment the default components.
    public var overrides: Components
    /// Content-specific components such as assets and templates used within the theme.
    public var content: Components

    /// Creates a new `Theme` instance.
    ///
    /// - Parameters:
    ///   - baseUrl: The base URL where the theme is located.
    ///   - components: The primary components of the theme.
    ///   - overrides: Override components that can replace or augment the default components.
    ///   - content: Content-specific components such as assets and templates used within the theme.
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

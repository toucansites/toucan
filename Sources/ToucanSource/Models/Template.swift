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
    // MARK: - Nested Types

    /// A group of assets and templates that make up a template component.
    public struct Components {
        // MARK: - Properties

        /// A list of asset file paths associated with the component.
        public var assets: [String]
        /// A list of templates associated with the component.
        public var views: [View]

        // MARK: - Lifecycle

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

    // MARK: - Properties

    /// The base URL where the template is located.
    public var baseURL: URL
    /// The primary components of the template.
    public var components: Components
    /// Override components that can replace or augment the default components.
    public var overrides: Components
    /// Content-specific components such as assets and templates used within the template.
    public var content: Components

    // MARK: - Lifecycle

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL where the template is located.
    ///   - components: The primary components of the template.
    ///   - overrides: Override components that can replace or augment the default components.
    ///   - content: Content-specific components such as assets and templates used within the template.
    public init(
        baseURL: URL,
        components: Components,
        overrides: Components,
        content: Components
    ) {
        self.baseURL = baseURL
        self.components = components
        self.overrides = overrides
        self.content = content
    }
}

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

    public var metadata: Metadata
    /// The primary components of the template.
    public var components: Components
    /// Override components that can replace or augment the default components.
    public var overrides: Components
    /// Content-specific components such as assets and templates used within the template.
    public var content: Components

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - components: The primary components of the template.
    ///   - overrides: Override components that can replace or augment the default components.
    ///   - content: Content-specific components such as assets and templates used within the template.
    public init(
        metadata: Metadata,
        components: Components,
        overrides: Components,
        content: Components
    ) {
        self.metadata = metadata
        self.components = components
        self.overrides = overrides
        self.content = content
    }
}

public extension Template {

    /// A group of assets and templates that make up a template component.
    struct Components {
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
}

extension Template {

    /// Returns a dictionary of template IDs and their contents.
    ///
    /// - Returns: A dictionary where the keys are template IDs and the values are their contents.
    public func getTemplatesIDsWithContents() -> [String: String] {
        let views = components.views + overrides.views + content.views
        let result = views.reduce(into: [String: String]()) {
            $0[$1.id] = $1.contents
        }

        return .init(uniqueKeysWithValues: result.sorted { $0.key < $1.key })
    }
}

public extension Template {

    struct Metadata: Codable {
        public var name: String
        public var description: String
        public var url: String
        public var version: String
        public var generatorVersions: [String]
        public var license: License
        public var author: Author
        public var demo: Demo
        public var tags: [String]
    }
}

public extension Template.Metadata {

    struct License: Codable {
        let name: String
        let url: String
    }
}

public extension Template.Metadata {

    struct Author: Codable {
        let name: String
        let url: String
    }
}

public extension Template.Metadata {

    struct Demo: Codable {
        let url: String
    }
}

//
//  Template.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import struct Foundation.URL
import Version

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

    /// Metadata associated with the template, such as author, version, and tags.
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
    ///   - metadata: Metadata associated with the template.
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
    public func getViewIDsWithContents() -> [String: String] {
        let views = components.views + overrides.views + content.views
        let result = views.reduce(into: [String: String]()) {
            $0[$1.id] = $1.contents
        }

        return .init(uniqueKeysWithValues: result.sorted { $0.key < $1.key })
    }
}

public extension Template {

    /// Metadata describing a template, such as name, version, license, and author.
    struct Metadata: Codable {
        /// The name of the template.
        public var name: String
        /// A short description of the template.
        public var description: String
        /// The URL where the template can be found or referenced.
        public var url: String?
        /// The version of the template.
        public var version: String?
        /// The versions of the generator this template is compatible with.
        public var generatorVersion: GeneratorVersion
        /// Licensing information for the template.
        public var license: License?
        /// Author information for the template.
        public var authors: [Author]?
        /// A demo link showing the template in action.
        public var demo: Demo?
        /// A list of tags to classify or describe the template.
        public var tags: [String]
    }
}

public extension Template.Metadata {

    struct GeneratorVersion: Codable, Sendable {

        private enum CodingKeys: CodingKey, CaseIterable {
            case value
            case type
        }

        /// The base version value that the template supports.
        public let value: Version

        /// The version comparison method used during validation.
        public let type: ComparisonType

        /// Initializes a new instance with the specified version and comparison type.
        /// - Parameters:
        ///   - value: The version to be used for comparison.
        ///   - type: The type of comparison to perform. Defaults to `.upNextMajor`.
        public init(
            value: Version,
            type: ComparisonType = .upNextMajor
        ) {
            self.value = value
            self.type = type
        }

        /// Initializes a new instance of the model from the given decoder.
        /// - Parameter decoder: The decoder to read data from.
        /// - Throws: An error if decoding fails or if unknown keys are present.
        /// - Note: Validates unknown keys using `CodingKeys`. The `type` property is defaulting to `.upNextMajor` if not present.
        public init(from decoder: any Decoder) throws {
            try decoder.validateUnknownKeys(keyType: CodingKeys.self)

            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.value = try container.decode(Version.self, forKey: .value)
            self.type =
                try container.decodeIfPresent(
                    ComparisonType.self,
                    forKey: .type
                ) ?? .upNextMajor
        }
    }
}

public extension Template.Metadata.GeneratorVersion {

    enum ComparisonType: String, Codable, Sendable {
        case upNextMajor
        case upNextMinor
        case exact
    }
}

public extension Template.Metadata {

    /// Licensing details for the template.
    struct License: Codable {
        /// The name of the license.
        let name: String
        /// The URL to the license text or information.
        let url: String?
    }
}

public extension Template.Metadata {

    /// Author details for the template.
    struct Author: Codable {
        /// The author's name.
        let name: String
        /// A URL to the author's website or profile.
        let url: String?
    }
}

public extension Template.Metadata {

    /// Demo resource reference for the template.
    struct Demo: Codable {
        /// A URL to the live demo or preview of the template.
        let url: String
    }
}

//
//  MustacheRenderer.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 16..
//

import Foundation
import Logging
import Mustache
import ToucanSource

/// Renders Mustache templates using a predefined template library and a dynamic context object.
public struct MustacheRenderer {

    /// A list of all available template IDs in the library.
    var ids: [String]

    /// The Mustache template library holding precompiled templates.
    var library: MustacheLibrary

    /// Logger used for reporting missing templates or rendering failures.
    var logger: Logger

    /// Initializes a renderer with a set of compiled Mustache templates and a logger.
    ///
    /// - Parameters:
    ///   - templates: A dictionary of template IDs and their corresponding `MustacheTemplate` objects.
    ///   - logger: A logger instance used for error reporting.
    public init(
        templates: [String: MustacheTemplate],
        logger: Logger
    ) {
        self.ids = Array(templates.keys)
        self.library = .init(templates: templates)
        self.logger = logger
    }

    /// Renders a Mustache template using the given context object.
    ///
    /// - Parameters:
    ///   - id: The ID of the template to render.
    ///   - object: A dictionary representing the context (`[String: AnyCodable]`).
    /// - Returns: The rendered HTML string, or `nil` if rendering fails or the template is missing.
    public func render(
        using id: String,
        with object: [String: AnyCodable]
    ) -> String? {
        // Ensure the ID is valid
        guard ids.contains(id) else {
            logger.error(
                "Missing or invalid template file.",
                metadata: [
                    "id": .string(id)
                ]
            )
            return nil
        }

        // Unwrap the object for rendering
        let local = unwrap(object) as Any

        // Attempt rendering using the Mustache library
        guard let html = library.render(local, withTemplate: id) else {
            logger.error(
                "Could not render HTML using the template file.",
                metadata: [
                    "id": .string(id)
                ]
            )
            return nil
        }
        return html
    }
}

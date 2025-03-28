//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

import Mustache
import Foundation
import ToucanModels
import Logging

public struct MustacheTemplateRenderer {

    var ids: [String]
    var library: MustacheLibrary
    var logger: Logger

    public init(
        templates: [String: MustacheTemplate],
        logger: Logger
    ) {
        self.ids = Array(templates.keys)
        self.library = .init(templates: templates)
        self.logger = logger
    }

    public func render(
        template: String,
        with object: [String: AnyCodable]
    ) throws -> String? {
        guard ids.contains(template) else {
            logger.error(
                "Missing or invalid template file.",
                metadata: [
                    "id": "\(template)"
                ]
            )
            return nil
        }
        let local = unwrap(object) as Any

        guard
            let html = library.render(local, withTemplate: template)
        else {
            logger.error(
                "Could not render HTML using the template file.",
                metadata: [
                    "id": "\(template)"
                ]
            )
            return nil
        }
        return html
    }
}

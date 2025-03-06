//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

import Mustache
import Foundation
import ToucanModels

public struct MustacheTemplateRenderer {

    var ids: [String]
    var library: MustacheLibrary

    public init(
        templates: [String: MustacheTemplate]
    ) {
        ids = Array(templates.keys)
        library = .init(templates: templates)
    }

    public func render(
        template: String,
        with object: [String: AnyCodable]
    ) throws -> String? {
        guard ids.contains(template) else {
            print("throw or error, missing template \(template)")
            return nil
        }
        let local = unwrap(object) as Any

        guard
            let html = library.render(local, withTemplate: template)
        else {
            print("nil html")
            return nil
        }
        return html
    }
}

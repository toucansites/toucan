//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

import ToucanCodable
import Mustache
import Foundation

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
        with object: [String: AnyCodable],
        to destination: URL
    ) throws {
        guard ids.contains(template) else {
            print("throw or error, missing template \(template)")
            return
        }
        // TODO: eliminate local
        let local = unwrap(object.dict("local")) as Any

        guard
            let html = library.render(local, withTemplate: template)
        else {
            print("nil html")
            return
        }
        try html.write(
            to: destination,
            atomically: true,
            encoding: .utf8
        )
    }

    // MARK: - unwrap AnyCodable

    private func unwrap(_ value: Any?) -> Any? {
        if let anyCodable = value as? AnyCodable {
            return unwrap(anyCodable.value)
        }
        if let dict = value as? [String: AnyCodable] {
            var result: [String: Any] = [:]
            for (key, val) in dict {
                result[key] = unwrap(val)
            }
            return result
        }
        if let dict = value as? [String: Any] {
            var result: [String: Any] = [:]
            for (key, val) in dict {
                result[key] = unwrap(val)
            }
            return result
        }
        if let array = value as? [Any] {
            return array.map { unwrap($0) }
        }
        return value
    }

}

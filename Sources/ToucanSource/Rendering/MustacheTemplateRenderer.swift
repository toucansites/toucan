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
        let local = object.dict("local").unwrapped()

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
}

extension Dictionary where Key == String, Value == AnyCodable {

    func unwrapped() -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in self {
            result[key] = value.unwrappedValue
        }
        return result
    }
}

extension AnyCodable {

    var unwrappedValue: Any? {
        if let dict = value as? [String: AnyCodable] {
            return dict.unwrapped()
        }
        if let array = value as? [AnyCodable] {
            return array.map { $0.unwrappedValue }
        }
        return value
    }
}

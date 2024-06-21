//
//  File.swift
//
//
//  Created by Tibor Bodecs on 23/05/2024.
//

import Foundation
import Mustache

extension String {

    func minifyHTML() -> Self {
        self
    }
}

struct MustacheToHTMLRenderer {

    enum Error: Swift.Error {
        case missingTemplate(String)
    }

    private let library: MustacheLibrary
    private let ids: [String]

    init(
        templatesUrl: URL,
        overridesUrl: URL
    ) throws {
        let ext = "mustache"
        var templates: [String: MustacheTemplate] = [:]

        if let dirContents = FileManager.default.enumerator(
            at: templatesUrl,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) {
            for case let url as URL in dirContents
            where url.pathExtension == ext {
                var relativePathComponents = url.pathComponents.dropFirst(
                    templatesUrl.pathComponents.count
                )
                let name = String(
                    relativePathComponents.removeLast()
                        .dropLast(".\(ext)".count)
                )
                relativePathComponents.append(name)
                let id = relativePathComponents.joined(separator: ".")
                templates[id] = try MustacheTemplate(
                    string: .init(contentsOf: url)
                )
            }
        }
        
        if let dirContents = FileManager.default.enumerator(
            at: overridesUrl,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) {
            for case let url as URL in dirContents
            where url.pathExtension == ext {
                var relativePathComponents = url.pathComponents.dropFirst(
                    overridesUrl.pathComponents.count
                )
                let name = String(
                    relativePathComponents.removeLast()
                        .dropLast(".\(ext)".count)
                )
                relativePathComponents.append(name)
                let id = relativePathComponents.joined(separator: ".")
                templates[id] = try MustacheTemplate(
                    string: .init(contentsOf: url)
                )
            }
        }
        
        
        self.library = MustacheLibrary(templates: templates)
        self.ids = Array(templates.keys)
        print("---")
        print(self.ids)
        print("---")
    }

    func render(
        template: String,
        with object: Any
    ) throws -> String? {
        guard self.ids.contains(template) else {
            throw Error.missingTemplate(template)
        }
        return library.render(object, withTemplate: template)
    }

    func render(
        template: String,
        with object: Any,
        to destination: URL
    ) throws {
        guard ids.contains(template) else {
            throw Error.missingTemplate(template)
        }
        try library.render(
            object,
            withTemplate: template
        )?
        .minifyHTML()
        .write(
            to: destination,
            atomically: true,
            encoding: .utf8
        )
    }
}

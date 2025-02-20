////
////  File.swift
////
////
////  Created by Tibor Bodecs on 23/05/2024.
////
//
//    init(
//        templatesUrl: URL,
//        overridesUrl: URL,
//        logger: Logger
//    ) throws {
//        var templates: [String: MustacheTemplate] = [:]
//        for (id, template) in try Self.loadTemplates(at: templatesUrl) {
//            templates[id] = template
//        }
//        for (id, template) in try Self.loadTemplates(at: overridesUrl) {
//            templates[id] = template
//        }
//
//        self.library = MustacheLibrary(templates: templates)
//        self.ids = Array(templates.keys)
//
//        logger.trace(
//            "Available templates: \(ids.sorted().map { "`\($0)`" }.joined(separator: ", "))"
//        )
//    }
//
//    // MARK: -
//
//    static func loadTemplates(
//        at templatesUrl: URL
//    ) throws -> [String: MustacheTemplate] {
//        let ext = "mustache"
//        var templates: [String: MustacheTemplate] = [:]
//        if let dirContents = FileManager.default.enumerator(
//            at: templatesUrl,
//            includingPropertiesForKeys: [.isRegularFileKey],
//            options: [.skipsHiddenFiles]
//        ) {
//            for case let url as URL in dirContents
//            where url.pathExtension == ext {
//                var relativePathComponents = url.pathComponents.dropFirst(
//                    templatesUrl.pathComponents.count
//                )
//                let name = String(
//                    relativePathComponents.removeLast()
//                        .dropLast(".\(ext)".count)
//                )
//                relativePathComponents.append(name)
//                let id = relativePathComponents.joined(separator: ".")
//                templates[id] = try MustacheTemplate(
//                    string: .init(contentsOf: url)
//                )
//            }
//        }
//        return templates
//    }
//
//    // MARK: -

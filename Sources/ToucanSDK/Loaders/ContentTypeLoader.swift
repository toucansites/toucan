////
////  File.swift
////  toucan
////
////  Created by Tibor Bodecs on 19/07/2024.
////
//
//import Foundation
//import Logging
//
///// A struct responsible for loading and managing content types.
//struct ContentTypeLoader {
//
//    let sourceConfig: SourceConfig
//
//    let fileLoader: FileLoader
//    let yamlParser: YamlParser
//
//    /// The logger instance
//    let logger: Logger
//
//    /// Loads and returns an array of content types.
//    ///
//    /// - Throws: An error if the content types could not be loaded.
//    /// - Returns: An array of `ContentType` objects.
//    func load() throws -> [ContentType] {
//
//        let typesUrl = sourceConfig.currentThemeTypesUrl
//        let overrideTypesUrl = sourceConfig.currentThemeOverrideTypesUrl
//        let contents = try fileLoader.findContents(at: typesUrl)
//        let overrideContents = try fileLoader.findContents(at: overrideTypesUrl)
//
//        let types = try contents.map {
//            try yamlParser.decode($0, as: ContentType.self)
//        }
//        let overrideTypes = try overrideContents.map {
//            try yamlParser.decode($0, as: ContentType.self)
//        }
//
//        var finalTypes: [ContentType] = overrideTypes
//        for type in types {
//            if !finalTypes.contains(where: { $0.id == type.id }) {
//                finalTypes.append(type)
//            }
//        }
//
//        // Adding the default content type if not present
//        if !finalTypes.contains(where: { $0.id == ContentType.default.id }) {
//            finalTypes.append(.default)
//        }
//
//        // NOTE: pagination type is not allowed
//        finalTypes = finalTypes.filter { $0.id != ContentType.pagination.id }
//        finalTypes.append(.pagination)
//
//        logger.debug(
//            "Available content types: `\(finalTypes.map(\.id).joined(separator: ", "))`."
//        )
//
//        return finalTypes
//    }
//}

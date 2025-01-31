//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import ToucanModels

extension RenderPipeline.Engine: Decodable {

    enum CodingKeys: CodingKey {
        case id
        case options
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let options = try container.decodeIfPresent(
            AnyValue.self,
            forKey: .options
        )

        self.init(
            id: id,
            options: options
        )
    }
}

extension RenderPipeline.Scope: Decodable {

    enum CodingKeys: CodingKey {
        case id
        case context
        case fields
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let context =
            try container.decodeIfPresent(
                Context.self,
                forKey: .context
            ) ?? .all
        let fields =
            try container.decodeIfPresent(
                [String].self,
                forKey: .fields
            ) ?? []

        self.init(
            id: id,
            context: context,
            fields: fields
        )
    }
}

extension RenderPipeline.Scope.Context: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self).lowercased()

        switch stringValue {
        case "properties":
            self = .properties
        case "contents":
            self = .contents
        case "relations":
            self = .relations
        case "queries":
            self = .queries
        case "all":
            self = .all
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid content type: \(stringValue)"
            )
        }
    }

}

extension RenderPipeline.ContentTypes: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self).lowercased()

        switch stringValue {
        case "single":
            self = .single
        case "bundle":
            self = .bundle
        case "all":
            self = .all
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid content type: \(stringValue)"
            )
        }
    }

    //    if let stringValue = try? container.decode(String.self) {
    //               self = ContentTypes.from(string: stringValue)
    //           } else if let stringArray = try? container.decode([String].self) {
    //               self = stringArray.reduce(into: ContentTypes()) { result, value in
    //                   result.insert(ContentTypes.from(string: value))
    //               }
    //           } else {
    //               throw DecodingError.dataCorruptedError(
    //                   in: container,
    //                   debugDescription: "Invalid content type format"
    //               )
    //           }
    //
    //    private func from(string: String) -> ContentTypes {
    //        switch string.lowercased() {
    //        case "single": return .single
    //        case "bundle": return .bundle
    //        case "all": return .all
    //        default: return []
    //        }
    //    }
}

extension RenderPipeline: Decodable {

    enum CodingKeys: CodingKey {
        case scopes
        case queries
        case contentType
        case engine
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let scopes =
            try container.decodeIfPresent(
                [String: [Scope]].self,
                forKey: .scopes
            ) ?? [:]

        let queries =
            try container.decodeIfPresent(
                [String: Query].self,
                forKey: .queries
            ) ?? [:]
        // TODO: make a choice which one should be the default: single vs all ?!?
        let contentType =
            try container.decodeIfPresent(
                ContentTypes.self,
                forKey: .contentType
            ) ?? .single
        let engine = try container.decode(Engine.self, forKey: .engine)

        self.init(
            scopes: scopes,
            queries: queries,
            contentType: contentType,
            engine: engine
        )
    }
}

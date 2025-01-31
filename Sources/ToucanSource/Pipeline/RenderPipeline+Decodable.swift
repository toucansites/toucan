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
        let options =
            try container.decodeIfPresent(
                [String: AnyValue].self,
                forKey: .options
            ) ?? [:]

        self.init(
            id: id,
            options: options
        )
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

}

extension RenderPipeline: Decodable {

    enum CodingKeys: CodingKey {
        case queries
        case contentType
        case engine
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

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
            queries: queries,
            contentType: contentType,
            engine: engine
        )
    }
}

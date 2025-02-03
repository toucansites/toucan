//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 01..
//

import Foundation
import ToucanModels

extension RenderPipeline.Scope: Decodable {

    enum CodingKeys: CodingKey {
        case id
        case context
        case fields
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

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
            context: context,
            fields: fields
        )
    }
}

//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 01..
//

import Foundation
import ToucanModels

extension RenderPipeline.ContentTypes: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self.init(stringValue: stringValue)
        }
        else if let stringArray = try? container.decode([String].self) {
            self = stringArray.reduce(into: []) {
                $0.insert(.init(stringValue: $1))
            }
        }
        else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ContentTypes format."
            )
        }

    }

}

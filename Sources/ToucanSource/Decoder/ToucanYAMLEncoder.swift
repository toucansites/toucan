//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 03. 06..
//

import Foundation
import Yams

public struct ToucanYAMLEncoder: ToucanEncoder {

    public init() {

    }

    public func encode<T: Encodable>(
        _ object: T
    ) throws(ToucanEncoderError) -> String {
        do {
            let encoder = YAMLEncoder()
            return try encoder.encode(object)
        }
        catch {
            throw .encoding(error)
        }
    }

}

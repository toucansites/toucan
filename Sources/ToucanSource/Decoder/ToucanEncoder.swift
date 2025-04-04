//
//  ToucanEncoder.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 03. 06..
//

import Foundation

public protocol ToucanEncoder {

    func encode<T: Encodable>(
        _ object: T
    ) throws(ToucanEncoderError) -> String
}

public enum ToucanEncoderError: Error {
    case encoding(Error, Any.Type)
}

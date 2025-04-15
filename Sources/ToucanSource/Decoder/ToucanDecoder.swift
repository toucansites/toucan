//
//  ToucanDecoder.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 29..
//

import Foundation

public protocol ToucanDecoder {

    func decode<T: Decodable>(
        _: T.Type,
        from: Data
    ) throws(ToucanDecoderError) -> T
}

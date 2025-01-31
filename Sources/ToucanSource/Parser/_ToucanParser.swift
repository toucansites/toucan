//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation

public protocol ToucanParser {

    func parse<T>(
        _: T.Type,
        from: Data
    ) throws(ToucanParserError) -> T
}

public enum ToucanParserError: Error {
    case data
    case parse(Error)
}

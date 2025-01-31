//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation

public struct ToucanJSONParser: ToucanParser {

    public var options: JSONSerialization.ReadingOptions

    public init(
        options: JSONSerialization.ReadingOptions = [
            .json5Allowed,
            .fragmentsAllowed,
            // .topLevelDictionaryAssumed,
        ]
    ) {
        self.options = options
    }

    public func parse<T>(
        _ type: T.Type,
        from data: Data
    ) throws(ToucanParserError) -> T {
        do {
            let json = try JSONSerialization.jsonObject(
                with: data,
                options: self.options
            )
            guard let object = json as? T else {
                throw ToucanParserError.data
            }
            return object
        }
        catch {
            throw ToucanParserError.parse(error)
        }
    }

}

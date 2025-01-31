//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import Yams

public struct ToucanYAMLParser: ToucanParser {

    public var resolver: Resolver

    public init(
        resolver: Resolver = .default.removing(.timestamp)
    ) {
        self.resolver = resolver
    }

    public func parse<T>(
        _ type: T.Type,
        from data: Data
    ) throws(ToucanParserError) -> T {
        do {
            guard
                let yaml = String(data: data, encoding: .utf8)
            else {
                throw ToucanParserError.data
            }
            guard
                let object = try Yams.load(yaml: yaml, resolver) as? T
            else {
                throw ToucanParserError.data
            }
            return object
        }
        catch {
            throw ToucanParserError.parse(error)
        }
    }

}

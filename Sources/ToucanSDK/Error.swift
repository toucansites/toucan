//
//  Error.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 04. 18..
//

public extension Toucan {

    enum Error: Swift.Error {
        case duplicateSlugs([String])
    }
}

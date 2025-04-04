//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 12..
//

import Foundation

extension String? {

    var nilToEmpty: String {
        switch self {
        case .none:
            return ""
        case .some(let value):
            return value
        }
    }

    var emptyToNil: String? {
        switch self {
        case .none:
            return nil
        case .some(let value):
            return value.isEmpty ? nil : self
        }
    }
}

extension String {

    var emptyToNil: String? {
        isEmpty ? nil : self
    }
}

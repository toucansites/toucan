//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 12..
//

import Foundation

extension String {

    func permalink(
        baseUrl: String
    ) -> String {
        let components = split(separator: "/").map(String.init)
        if components.isEmpty {
            return baseUrl
        }
        if components.last?.split(separator: ".").count ?? 0 > 1 {
            return ([baseUrl] + components).joined(separator: "/")
        }
        return ([baseUrl] + components).joined(separator: "/") + "/"
    }
}

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

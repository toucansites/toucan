//
//  ToucanDecoderError.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 17..
//

import ToucanCore

extension DecodingError.Context {

    var logMessage: String {
        if codingPath.isEmpty {
            return debugDescription
        }
        return codingPath.map(\.description).joined(separator: ".")
    }
}

extension DecodingError: ToucanError {

    public var logMessage: String {
        switch self {
        case let .dataCorrupted(context):
            "Data corrupted: \(context.logMessage)"
        case let .keyNotFound(key, context):
            "Key not found: \(key) - \(context.logMessage)"
        case let .typeMismatch(type, context):
            "Type mismatch: \(type) - \(context.logMessage)"
        case let .valueNotFound(type, context):
            "Value not found: \(type) - \(context.logMessage)"
        default:
            "\(self)"
        }
    }

    public var userFriendlyMessage: String {
        localizedDescription
    }
}

public struct ToucanDecoderError: ToucanError {

    let type: Any.Type
    let error: Error?

    init(
        type: Any.Type,
        error: Error? = nil
    ) {
        self.type = type
        self.error = error
    }

    public var underlyingErrors: [any Error] {
        error.map { [$0] } ?? []
    }

    public var logMessage: String {
        "Type decoding error: `\(type)`."
    }

    public var userFriendlyMessage: String {
        "Could not decode object."
    }
}

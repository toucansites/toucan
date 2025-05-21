//
//  ToucanEncoderError.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 17..
//

import ToucanCore

extension EncodingError: ToucanError {

    public var logMessage: String {
        "\(self)"
    }

    public var userFriendlyMessage: String {
        localizedDescription
    }
}

public struct ToucanEncoderError: ToucanError {

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
        "Type encoding error: `\(type)`."
    }

    public var userFriendlyMessage: String {
        "Could not encode object."
    }
}

//
//  ToucanError.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 20..
//

import Foundation

public protocol ToucanError: Error {
    var logMessage: String { get }
    var userFriendlyMessage: String { get }
    var underlyingErrors: [Error] { get }
    func logMessageStack() -> String
}

extension NSError: ToucanError {

    public var logMessage: String {
        "\(domain):\(code) - \(localizedDescription)"
    }

    public var userFriendlyMessage: String {
        "\(localizedDescription)"
    }
}

extension ToucanError {

    public var underlyingErrors: [Error] { [] }

    public func logMessageStack() -> String {
        format(error: self)
    }

    private func format(
        error: Error,
        prefix: String = "",
        isLast: Bool = true
    ) -> String {
        let type = type(of: error)

        var message: String
        var underlyingErrors: [Error]
        switch error {
        case let e as ToucanError:
            message = e.logMessage
            underlyingErrors = e.underlyingErrors
        case let e as LocalizedError:
            message = e.localizedDescription
            underlyingErrors = []
        default:
            message = "\(error)"
            underlyingErrors = []
        }

        let branch = prefix.isEmpty ? "" : (isLast ? "└─ " : "├─ ")
        var output = "\(prefix)\(branch)\(type): \"\(message)\"\n"
        let childPrefix = prefix + (isLast ? "    " : "│   ")

        let childCount = underlyingErrors.count
        for (idx, error) in underlyingErrors.enumerated() {
            let lastChild = (idx == childCount - 1)
            output += format(
                error: error,
                prefix: childPrefix,
                isLast: lastChild
            )
        }

        return output
    }
}

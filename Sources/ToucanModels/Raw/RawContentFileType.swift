//
//  RawContentFileType.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 12..
//

public enum RawContentFileType {
    case markdown
    case yaml

    public var extensions: [String] {
        switch self {
        case .markdown:
            return ["md", "markdown"]
        case .yaml:
            return ["yaml", "yml"]
        }
    }
}

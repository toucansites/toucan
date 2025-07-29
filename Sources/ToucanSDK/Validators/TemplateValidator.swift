//
//  TemplateValidator.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 06. 17..
//

import Foundation
import ToucanCore
import ToucanSource
import Version

enum TemplateValidatorError: ToucanError {
    case invalidVersion(String)
    case noSupportedGeneratorVersion(version: Version, supported: [Version])

    var logMessage: String {
        switch self {
        case let .invalidVersion(value):
            return "Invalid version: `\(value)`."
        case let .noSupportedGeneratorVersion(version, supported):
            let supportedList = supported.map { "`\($0)`" }
                .joined(separator: ", ")
            return
                "Generator version `\(version)` is not supported. Supported versions: \(supportedList)."
        }
    }

    var userFriendlyMessage: String {
        logMessage
    }
}

struct TemplateValidator {

    let version: Version

    init(generatorInfo: GeneratorInfo = .current) throws {
        let rawVersion = generatorInfo.release
        let version = Version(rawVersion)
        guard let version else {
            throw TemplateValidatorError.invalidVersion(rawVersion)
        }
        self.version = version
    }

    func validate(_ template: Template) throws(TemplateValidatorError) {
        let versions = try template.metadata.generatorVersions
            .map { version throws(TemplateValidatorError) -> Version in
                guard let version = Version(version) else {
                    throw .invalidVersion(version)
                }
                return version
            }
            .sorted()

        if !versions.contains(version) {
            throw .noSupportedGeneratorVersion(
                version: version,
                supported: versions
            )
        }
    }
}

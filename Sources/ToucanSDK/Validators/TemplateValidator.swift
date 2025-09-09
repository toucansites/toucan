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
    case unsupportedGeneratorVersion(
        generatorVersion: Template.Metadata.GeneratorVersion,
        currentVersion: Version
    )

    var logMessage: String {
        switch self {
        case let .unsupportedGeneratorVersion(generatorVersion, currentVersion):
            return
                "Unsupported generator version: `\(generatorVersion.type)(\(generatorVersion.value))`. Current Toucan version: \(currentVersion)."
        }
    }

    var userFriendlyMessage: String {
        logMessage
    }
}

struct TemplateValidator {

    let version: Version

    init(generatorInfo: GeneratorInfo = .current) throws {
        self.version = generatorInfo.release
    }

    func validate(_ template: Template) throws(TemplateValidatorError) {
        let generatorVersion = template.metadata.generatorVersion
        let isSupported: Bool

        switch generatorVersion.type {
        case .upNextMajor:
            let lowerBound = generatorVersion.value
            let upperBound = Version(generatorVersion.value.major + 1, 0, 0)
            isSupported = (lowerBound..<upperBound).contains(version)
        case .upNextMinor:
            let lowerBound = generatorVersion.value
            let upperBound = Version(
                generatorVersion.value.major,
                generatorVersion.value.minor + 1,
                0
            )
            isSupported = (lowerBound..<upperBound).contains(version)
        case .exact:
            isSupported = generatorVersion.value == version
        }

        if !isSupported {
            throw .unsupportedGeneratorVersion(
                generatorVersion: generatorVersion,
                currentVersion: version
            )
        }
    }
}

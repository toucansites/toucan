//
//  ToucanTestSuite+Configs.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 09.
//

import Testing
import Logging
import Foundation
import FileManagerKitTesting
import ToucanTesting
@testable import ToucanSDK

extension ToucanTestSuite {

    func contentSiteFile() -> File {
        File(
            "site.yml",
            string: """
                baseUrl: http://localhost:3000/
                locale: en-US
                title: Test
                navigation:
                    - label: "Home"
                      url: "/"
                    - label: "About"
                      url: "/about/"
                """
        )
    }

    func configFile() -> File {
        File(
            "config.yml",
            string: """
                dateFormats:
                    input: 
                        format: "yyyy-MM-dd HH:mm:ss"
                    output:
                        year: 
                            format: "y"
                """
        )
    }

    func replaceScriptFile() -> File {
        File(
            "replace",
            attributes: [.posixPermissions: 0o777],
            string: """
                #!/bin/bash
                # Replaces all colons `:` with dashes `-` in the given file.
                # Usage: replace-char --file <path>
                UNKNOWN_ARGS=()
                while [[ $# -gt 0 ]]; do
                    case $1 in
                        --file)
                            TOUCAN_FILE="$2"
                            shift
                            shift
                            ;;
                        -*|--*)
                            UNKNOWN_ARGS+=("$1" "$2")
                            shift
                            shift
                            ;;
                        *)
                            shift
                            ;;
                    esac
                done
                if [[ -z "${TOUCAN_FILE}" ]]; then
                    echo "❌ No file specified with --file."
                    exit 1
                fi
                echo "📄 Processing file: ${TOUCAN_FILE}"
                if [[ ${#UNKNOWN_ARGS[@]} -gt 0 ]]; then
                    echo "ℹ️ Ignored unknown options: ${UNKNOWN_ARGS[*]}"
                fi
                sed 's/:/-/g' "${TOUCAN_FILE}" > "${TOUCAN_FILE}.tmp" && mv "${TOUCAN_FILE}.tmp" "${TOUCAN_FILE}"
                echo "✅ Done replacing characters."
                """
        )
    }

}

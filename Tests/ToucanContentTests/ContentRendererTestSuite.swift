import Foundation
import Testing
import Logging
@testable import ToucanContent
@testable import ToucanModels

@Suite
struct ContentRendererTestSuite {

    @Test
    func basicRendering() throws {
        let logger = Logger(label: "ContentRendererTestSuite")
        let renderer = ContentRenderer(
            configuration: .init(
                markdown: .init(
                    customBlockDirectives: [
                        .init(
                            name: "FAQ",
                            parameters: nil,
                            requiresParentDirective: nil,
                            removesChildParagraph: nil,
                            tag: "div",
                            attributes: [
                                .init(name: "class", value: "faq")
                            ],
                            output: nil
                        )
                    ]
                ),
                outline: .init(
                    levels: [2, 3]
                ),
                readingTime: .init(
                    wordsPerMinute: 238
                ),
                transformerPipeline: nil,
                paragraphStyles: ParagraphStyles.defaults
            ),
            fileManager: FileManager.default,
            logger: logger
        )

        let input = #"""
            @FAQ {
                ## test 
                Lorem ipsum
            }
            """#

        let contents = renderer.render(
            content: input,
            slug: "",
            assetsPath: "",
            baseUrl: ""
        )

        let html = #"""
            <div class="faq"><h2 id="test">test</h2><p>Lorem ipsum</p></div>
            """#

        #expect(contents.html == html)
        #expect(
            contents.outline == [
                .init(
                    level: 2,
                    text: "test",
                    fragment: "test"
                )
            ]
        )
        #expect(contents.readingTime == 1)
    }

    /// Tests the `ContentRenderer`'s transformer pipeline using the "replace-char" script.
    /// Requires the external script `/usr/local/bin/replace-char` to be available.
    @Test(
        .disabled(
            if: !isReplaceCharScriptAvailable,
            "Requires the `/usr/local/bin/replace-char` script. See `isReplaceCharScriptAvailable` for more information!"
        )
    )
    func transformers() throws {
        let logger = Logger(label: "ContentRendererTestSuite")
        let renderer = ContentRenderer(
            configuration: .init(
                markdown: .init(customBlockDirectives: []),
                outline: .init(levels: [2, 3]),
                readingTime: .init(wordsPerMinute: 238),
                transformerPipeline: .init(
                    run: [
                        .init(
                            name: "replace-char",
                            arguments: [:]
                        )
                    ],
                    isMarkdownResult: false
                ),
                paragraphStyles: ParagraphStyles.defaults
            ),
            fileManager: FileManager.default,
            logger: logger
        )

        let input = "Character to replace => :"

        let contents = renderer.render(
            content: input,
            slug: "home",
            assetsPath: "assets/home",
            baseUrl: "http://localhost:3000"
        )

        let html = "Character to replace => -"

        #expect(contents.html == html)
    }
}

extension ContentRendererTestSuite {

    /**
    A helper script that needs to be installed at `/usr/local/bin/replace-char` to be able to run certain tests.
    To install the script, copy this block until EOF and paste it into your terminal:

    ```bash
    cat > replace-char << 'EOF'
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
    EOF
    ```

    Then give executable permission:
    ```bach
    chmod +x replace-char
    ```

    Finally move it to `/usr/local/bin`.
    ```
    sudo mv replace-char /usr/local/bin/replace-char
    ```
    */
    static var isReplaceCharScriptAvailable: Bool {
        FileManager.default
            .isExecutableFile(atPath: "/usr/local/bin/replace-char")
    }
}

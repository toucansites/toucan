import Foundation
import Ink
import Splash

struct ContentParser {

    func parse(
        at url: URL,
        baseUrl: String,
        slug: String,
        assets: [String]
    ) throws -> String {
        let parser = createParser(
            baseUrl: baseUrl,
            slug: slug,
            assets: assets
        )
        let rawMarkdown = try String(contentsOf: url)
        return parser.parse(rawMarkdown).html
    }

    func createParser(
        baseUrl: String,
        slug: String,
        assets: [String]
    ) -> MarkdownParser {
        let linkModifier = Modifier(target: .links) { html, markdown in
            if !html.contains(baseUrl) {
                return html.replacingOccurrences(
                    of: "\">",
                    with: "\" target=\"_blank\">"
                )
            }
            return html
        }

        let bqModifier = Modifier(target: .blockquotes) { html, markdown in
            if markdown.hasPrefix("> NOTE: ") {
                return html.replacingOccurrences([
                    "NOTE: ": "",
                    "<p>": "<p class=\"note\">",
                    "<blockquote>": "",
                    "</blockquote>": "",
                ])
            }
            if markdown.hasPrefix("> WARN: ") {
                return html.replacingOccurrences([
                    "WARN: ": "",
                    "<p>": "<p class=\"warning\">",
                    "<blockquote>": "",
                    "</blockquote>": "",
                ])
            }
            return html
        }

        let highlighter = SyntaxHighlighter(format: HTMLOutputFormat())
        let splashModifier = Modifier(target: .codeBlocks) { html, markdown in
            var input = String(markdown)
            guard input.hasPrefix("```swift") else {
                return html
            }
            input = String(input.dropFirst(8).dropLast(3))
            let code = highlighter.highlight(input).trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            return #"<pre><code class="language-swift">\#(code)</code></pre>"#
        }

        let imageModifier = Modifier(target: .images) { html, markdown in
            let input = String(markdown)
            guard
                let alt = input.slice(from: "![", to: "]"),
                let file = input.slice(from: "](", to: ")"),
                let name = file.split(separator: ".").first,
                let ext = file.split(separator: ".").last,
                assets.contains(file)
            else {
                print("[WARNING] Image link issues `\(input)` in `\(slug)`.")
                return html
            }

            let darkFile = String(name) + "~dark." + String(ext)
            let src = baseUrl + "images/assets/" + slug + "/images/" + file
            let darkSrc =
                baseUrl + "images/assets/" + slug + "/images/" + darkFile

            var dark = ""
            if assets.contains(darkFile) {
                dark =
                    #"<source srcset="\#(darkSrc)" media="(prefers-color-scheme: dark)">\#n\#t\#t"#
            }
            return #"""
                </section><section class="wrapper">
                <figure>
                    <picture>
                        \#(dark)<img class="post-image" src="\#(src)" alt="\#(alt)">
                    </picture>
                </figure>
                </section><section class="content-wrapper">
                """#
        }

        var parser = MarkdownParser()
        let modifiers = [
            linkModifier,
            splashModifier,
            imageModifier,
            bqModifier,
        ]
        for modifier in modifiers {
            parser.addModifier(modifier)
        }
        return parser
    }
}

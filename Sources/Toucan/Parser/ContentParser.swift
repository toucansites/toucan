import Foundation

//        let linkModifier = Modifier(target: .links) { html, markdown in
//            if !html.contains(baseUrl) {
//                return html.replacingOccurrences(
//                    of: "\">",
//                    with: "\" target=\"_blank\">"
//                )
//            }
//            return html
//        }
//
//        let bqModifier = Modifier(target: .blockquotes) { html, markdown in
//            if markdown.hasPrefix("> NOTE: ") {
//                return html.replacingOccurrences([
//                    "NOTE: ": "",
//                    "<p>": "<p class=\"note\">",
//                    "<blockquote>": "",
//                    "</blockquote>": "",
//                ])
//            }
//            if markdown.hasPrefix("> WARN: ") {
//                return html.replacingOccurrences([
//                    "WARN: ": "",
//                    "<p>": "<p class=\"warning\">",
//                    "<blockquote>": "",
//                    "</blockquote>": "",
//                ])
//            }
//            return html
//        }
//
//
//
//        let imageModifier = Modifier(target: .images) { html, markdown in
//            let input = String(markdown)
//            guard
//                let alt = input.slice(from: "![", to: "]"),
//                let file = input.slice(from: "](", to: ")"),
//                let name = file.split(separator: ".").first,
//                let ext = file.split(separator: ".").last,
//                assets.contains(file)
//            else {
//                print("[WARNING] Image link issues `\(input)` in `\(slug)`.")
//                return html
//            }
//
//            let darkFile = String(name) + "~dark." + String(ext)
//            let src = baseUrl + "images/assets/" + slug + "/images/" + file
//            let darkSrc =
//                baseUrl + "images/assets/" + slug + "/images/" + darkFile
//
//            var dark = ""
//            if assets.contains(darkFile) {
//                dark =
//                    #"<source srcset="\#(darkSrc)" media="(prefers-color-scheme: dark)">\#n\#t\#t"#
//            }
//            return #"""
//                </section><section class="wrapper">
//                <figure>
//                    <picture>
//                        \#(dark)<img class="post-image" src="\#(src)" alt="\#(alt)">
//                    </picture>
//                </figure>
//                </section><section class="content-wrapper">
//                """#
//        }
//

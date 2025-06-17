//
//  Mocks+Files.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 15..
//

import FileManagerKitBuilder
import Foundation

extension File {
    enum Mocks {}
}

extension File.Mocks {
    // MARK: -

    static func replaceTransformer() -> File {
        .init(
            name: "replace",
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

    // MARK: -

    static func templateCSS() -> File {
        File(
            name: "template.css",
            string: """
                header, footer, .page {
                    max-width: 800px;
                    margin: 0 auto;
                }
                header {
                    text-align: center;
                    border-bottom: 1px dotted black;
                    padding-bottom: 16px;
                }
                footer {
                    text-align: center;
                    border-top: 1px dotted black;
                    padding-top: 16px;
                }
                .page {
                    padding-top: 16px;
                    padding-bottom: 16px;
                }
                header #logo img {
                    width: 64px;
                }
                """
        )
    }

    // MARK: -

    static func template404View() -> MustacheFile {
        .init(
            name: "404",
            template: Mocks.Views.notFound()
        )
    }

    static func templateDefaultView() -> MustacheFile {
        .init(
            name: "default",
            template: Mocks.Views.page()
        )
    }

    static func templateHomeView() -> MustacheFile {
        .init(
            name: "home",
            template: Mocks.Views.home()
        )
    }

    static func templateFooterView() -> MustacheFile {
        .init(
            name: "footer",
            template: """
                <footer>
                    <p>This site was generated using <a href="https://www.swift.org/" target="_blank">Swift</a> & <a href="https://github.com/toucansites/toucan" target="_blank">Toucan</a>.</p>

                    <p class="small">{{site.title}} &copy; {{site.generation.formats.year}}.</p>
                </footer>
                """
        )
    }

    static func templateHeaderView() -> MustacheFile {
        .init(
            name: "header",
            template: """
                <header>
                    <a id="logo" href="/">
                        <img
                            src="{{site.baseUrl}}/images/logo.png"
                            alt="Logo of {{site.title}}"
                            title="{{site.title}}"
                        >
                    </a>
                    <nav>
                        <div class="navigation">
                            {{#site.navigation}}
                            <a href="{{url}}"{{#class}} class="{{.}}"{{/class}}>{{label}}</a>
                            {{/site.navigation}}
                        </div>
                    </nav>
                </header>
                """
        )
    }

    static func templateHTMLView() -> MustacheFile {
        .init(
            name: "html",
            template: Mocks.Views.html()
        )
    }

    static func templateRedirectView() -> MustacheFile {
        .init(
            name: "redirect",
            template: Mocks.Views.redirect()
        )
    }

    static func templateRSSView() -> MustacheFile {
        .init(
            name: "rss.mustache",
            template: Mocks.Views.rss()
        )
    }

    static func templateSitemapView() -> MustacheFile {
        .init(
            name: "sitemap.mustache",
            template: Mocks.Views.sitemap()
        )
    }

    // MARK: -

    static func notFoundPage() -> RawContentBundle {
        .init(
            name: "404",
            rawContent: Mocks.RawContents.notFoundPage()
        )
    }

    static func aboutPage() -> RawContentBundle {
        .init(
            name: "about",
            rawContent: Mocks.RawContents.aboutPage()
        )
    }

    static func aboutPageStyleCSS() -> File {
        File(
            name: "style.css",
            string: """
                #home h1 {
                    text-transform: uppercase;
                }
                """
        )
    }

    static func homePage() -> MarkdownFile {
        .init(
            name: "index",
            markdown: Mocks.RawContents.homePage().markdown
        )
    }

    static func post(
        id: Int,
        now: Date = .init(),
        publication: String,
        expiration: String,
        draft: Bool,
        featured: Bool,
        authorIDs: [Int],
        tagIDs: [Int]
    ) -> RawContentBundle {
        .init(
            name: "post-\(id)",
            rawContent: Mocks.RawContents.post(
                id: id,
                now: now,
                publication: publication,
                expiration: expiration,
                draft: draft,
                featured: featured,
                authorIDs: authorIDs,
                tagIDs: tagIDs
            )
        )
    }

    static func rssBundle() -> Directory {
        Directory(name: "rss.xml") {
            File(
                name: "index.yml",
                string: """
                    type: rss
                    """
            )
        }
    }

    static func sitemapBundle() -> Directory {
        Directory(name: "sitemap.xml") {
            File(
                name: "index.yml",
                string: """
                    type: sitemap
                    """
            )
        }
    }

    // MARK: - misc

    static func svg1() -> File {
        File(
            name: "test1.svg",
            string: """
                <svg width="800px" height="800px" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M6.46967 10.0303C6.17678 9.73744 6.17678 9.26256 6.46967 8.96967L11.4697 3.96967C11.7626 3.67678 12.2374 3.67678 12.5303 3.96967L17.5303 8.96967C17.8232 9.26256 17.8232 9.73744 17.5303 10.0303C17.2374 10.3232 16.7626 10.3232 16.4697 10.0303L12.75 6.31066L12.75 14.5C12.75 15.2133 12.9702 16.3 13.6087 17.1868C14.2196 18.0353 15.2444 18.75 17 18.75C17.4142 18.75 17.75 19.0858 17.75 19.5C17.75 19.9142 17.4142 20.25 17 20.25C14.7556 20.25 13.2804 19.298 12.3913 18.0632C11.5298 16.8667 11.25 15.4534 11.25 14.5L11.25 6.31066L7.53033 10.0303C7.23744 10.3232 6.76256 10.3232 6.46967 10.0303Z" fill="#1C274C"/>
                </svg>
                """
        )
    }

    static func svg2() -> File {
        File(
            name: "test2.svg",
            string: """
                <svg width="800px" height="800px" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M6.46967 10.0303C6.17678 9.73744 6.17678 9.26256 6.46967 8.96967L11.4697 3.96967C11.7626 3.67678 12.2374 3.67678 12.5303 3.96967L17.5303 8.96967C17.8232 9.26256 17.8232 9.73744 17.5303 10.0303C17.2374 10.3232 16.7626 10.3232 16.4697 10.0303L12.75 6.31066L12.75 14.5C12.75 15.2133 12.9702 16.3 13.6087 17.1868C14.2196 18.0353 15.2444 18.75 17 18.75C17.4142 18.75 17.75 19.0858 17.75 19.5C17.75 19.9142 17.4142 20.25 17 20.25C14.7556 20.25 13.2804 19.298 12.3913 18.0632C11.5298 16.8667 11.25 15.4534 11.25 14.5L11.25 6.31066L7.53033 10.0303C7.23744 10.3232 6.76256 10.3232 6.46967 10.0303Z" fill="#1C274C"/>
                </svg>
                """
        )
    }

    static func yaml1() -> File {
        File(
            name: "test1.yaml",
            string: """
                key1: value1
                key2: value2
                """
        )
    }

    static func yaml2() -> File {
        File(
            name: "test2.yaml",
            string: """
                key3: value3
                key4: value4
                """
        )
    }
}

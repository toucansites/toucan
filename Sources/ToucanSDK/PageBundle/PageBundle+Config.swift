//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 11..
//

import Foundation

extension PageBundle {

    struct Config {

        public enum Keys {

            static let slug = "slug"
            static let type = "type"

            static let title = "title"
            static let description = "description"
            static let image = "image"

            static let draft = "draft"
            static let publication = "publication"
            static let expiration = "expiration"

            static let assets = "assets"
            static let template = "template"
            static let output = "output"

            static let redirects = "redirects"
            static let noindex = "noindex"
            static let canonical = "canonical"
            static let hreflang = "hreflang"

            static let css = "css"
            static let js = "js"

            static let allKeys = [
                Keys.draft,
                Keys.publication,
                Keys.expiration,
                Keys.slug,
                Keys.type,
                Keys.title,
                Keys.description,
                Keys.image,
                Keys.template,
                Keys.output,
                Keys.assets,
                Keys.redirects,
                Keys.noindex,
                Keys.canonical,
                Keys.hreflang,
                Keys.css,
                Keys.js,
            ]
        }

        struct Hreflang {
            let lang: String
            let url: String
        }

        struct Redirect {

            enum Code: Int, CaseIterable {
                case movedPermanently = 301
                case seeOther = 303
                case permanentRedirect = 308
            }

            let from: String
            let code: Code
        }

        struct Assets {

            public enum Keys {
                static let folder = "folder"
            }

            let folder: String

            init(folder: String) {
                self.folder = folder
            }

            init(_ dict: [String: Any]) {
                self.folder = dict.string(Keys.folder) ?? "assets"
            }
        }

        let slug: String?
        let type: String?

        let title: String?
        let description: String?
        let image: String?

        let assets: Assets
        let template: String?
        let output: String?

        let draft: Bool
        let publication: String?
        let expiration: String?

        let noindex: Bool
        let canonical: String?
        let hreflang: [Hreflang]
        let redirects: [Redirect]

        let css: [String]
        let js: [String]

        let userDefined: [String: Any]

        init(
            slug: String?,
            type: String?,
            title: String?,
            description: String?,
            image: String?,
            assets: PageBundle.Config.Assets,
            template: String?,
            output: String?,
            draft: Bool,
            publication: String?,
            expiration: String?,
            noindex: Bool,
            canonical: String?,
            hreflang: [PageBundle.Config.Hreflang],
            redirects: [PageBundle.Config.Redirect],
            css: [String],
            js: [String],
            userDefined: [String: Any]
        ) {
            self.slug = slug
            self.type = type
            self.title = title
            self.description = description
            self.image = image
            self.assets = assets
            self.template = template
            self.output = output
            self.draft = draft
            self.publication = publication
            self.expiration = expiration
            self.noindex = noindex
            self.canonical = canonical
            self.hreflang = hreflang
            self.redirects = redirects
            self.css = css
            self.js = js
            self.userDefined = userDefined
        }

        init(
            _ dict: [String: Any]
        ) {
            self.slug = dict.string(Keys.slug)
            self.type = dict.string(Keys.type)

            self.title = dict.string(Keys.title)
            self.description = dict.string(Keys.description)
            self.image = dict.string(Keys.image)

            self.template =
                dict.string(Keys.template) ?? ContentType.default.template

            self.output = dict.string(Keys.output)

            self.publication = dict.string(Keys.publication)

            self.expiration = dict.string(Keys.expiration)

            self.draft =
                dict.bool(Keys.draft)
                ?? false

            self.assets = .init(dict.dict(Keys.assets))

            self.noindex =
                dict.bool(Keys.noindex)
                ?? false

            self.canonical =
                dict.string(Keys.canonical)

            self.hreflang =
                dict.array(Keys.hreflang, as: [String: Any].self)
                .compactMap { dict in
                    guard
                        let lang = dict.string("lang"),
                        let url = dict.string("url")
                    else {
                        return nil
                    }
                    return .init(lang: lang, url: url)
                }

            self.redirects =
                dict.array(Keys.redirects, as: [String: Any].self)
                .compactMap { dict -> Redirect? in
                    guard let from = dict.string("from") else {
                        return nil
                    }
                    let code =
                        dict.int("code")
                        .flatMap { Redirect.Code(rawValue: $0) }
                        ?? .movedPermanently
                    return .init(from: from, code: code)
                }

            self.css =
                dict.array(Keys.css, as: String.self)

            self.js =
                dict.array(Keys.js, as: String.self)

            self.userDefined = dict.filter { !Keys.allKeys.contains($0.key) }
        }
    }
}

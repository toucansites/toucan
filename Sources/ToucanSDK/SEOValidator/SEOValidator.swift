//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 28..
//

import Foundation
import Logging
import SwiftSoup

extension SwiftSoup.Document {

    public func selectFirst(_ query: String) throws -> Element? {
        try select(query).first()
    }

    func getTitle() throws -> String? {
        try selectFirst("title")?.text()
    }

    //    func getAttribute(_ key: String) throws -> String? {
    //        try attr(key)
    //    }
}

public struct SEOValidator {

    public enum Error: Swift.Error {
        case validation(String)
    }

    let logger: Logger

    public init(logger: Logger) {
        self.logger = logger
    }

    func validate(
        html: String,
        using pageBundle: PageBundle
    ) {
        let metadata: Logger.Metadata = [
            "type": "\(pageBundle.contentType.id)",
            "slug": "\(pageBundle.slug)",
        ]

        do {
            let document: SwiftSoup.Document = try SwiftSoup.parse(html)
            guard let title = try document.getTitle() else {
                throw Error.validation("Title not found")
            }
            //            if title.count < 55 {
            //                logger.warning(
            //                    "Title is too short, use minimum 55 characters.",
            //                    metadata: metadata
            //                )
            //            }
            //            if title.count > 65 {
            //                logger.warning(
            //                    "Title is too long, use maximum 65 characters.",
            //                    metadata: metadata
            //                )
            //            }
            //            if title.count > 70 {
            //                logger.error(
            //                    "Title is way too long, use maximum 70 characters.",
            //                    metadata: metadata
            //                )
            //            }

            var isCanonicalLinkPresent = false
            let links = try document.select("link")
            for link in links {
                let rel = try link.attr("rel")
                if rel == "canonical" {
                    isCanonicalLinkPresent = true
                }
            }
            if !isCanonicalLinkPresent {
                logger.warning(
                    "Canonical link not present",
                    metadata: metadata
                )
            }

            if let keyword = pageBundle.frontMatter.string("keyword") {
                if !title.contains(keyword) {
                    logger.warning(
                        "Title does not contain keyword: `\(keyword)`.",
                        metadata: metadata
                    )
                }
            }

            let headings = try document.select("h1, h2, h3, h4, h5, h6")
            var currentLevel = 1

            for element in headings {
                guard let level = Int(element.nodeName().dropFirst()) else {
                    logger.error("Invalid heading level.")
                    continue
                }
                let text = try element.text()
                if level == 1 {
                    if text.count > 80 {
                        logger.warning(
                            "Heading 1 should be 80 characters or less."
                        )
                    }
                }

                if level > currentLevel + 1 {
                    logger.warning("Missing heading level \(currentLevel + 1).")
                }
                currentLevel = level

                //                print(text)
            }
        }
        catch Exception.Error(_, let message) {
            logger.error("\(message)")
        }
        catch {
            logger.error("\(error.localizedDescription)")
        }
    }

    func validate(
        pageBundle: PageBundle
    ) {
        guard pageBundle.contentType.id != ContentType.pagination.id else {
            return
        }
        let metadata: Logger.Metadata = [
            "type": "\(pageBundle.contentType.id)",
            "slug": "\(pageBundle.slug)",
        ]

        // check title
        if pageBundle.title.count < 55 {
            logger.warning(
                "Title is too short, use minimum 55 characters.",
                metadata: metadata
            )
        }
        if pageBundle.title.count > 65 {
            logger.warning(
                "Title is too long, use maximum 65 characters.",
                metadata: metadata
            )
        }
        if pageBundle.title.count > 70 {
            logger.error(
                "Title is way too long, use maximum 70 characters.",
                metadata: metadata
            )
        }
        // check description
        if pageBundle.description.count < 50 {
            logger.warning(
                "Description is too short, use minimum 55 characters.",
                metadata: metadata
            )
        }
        if pageBundle.description.count > 160 {
            logger.warning(
                "Description is too long, use maximum 65 characters.",
                metadata: metadata
            )
        }
        if pageBundle.description.count > 165 {
            logger.error(
                "Description is way too long, use maximum 70 characters.",
                metadata: metadata
            )
        }

        // check keyword

        if let keyword = pageBundle.frontMatter.string("keyword") {
            if !pageBundle.title.contains(keyword) {
                logger.warning(
                    "Title does not contain keyword: `\(keyword)`.",
                    metadata: metadata
                )
            }
            if !pageBundle.description.contains(keyword) {
                logger.warning(
                    "Description does not contain keyword: `\(keyword)`.",
                    metadata: metadata
                )
            }
        }
    }
}

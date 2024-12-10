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

    func getDescription() throws -> String? {
        let metas = try select("meta")
        for meta in metas {
            let name = try meta.attr("name")
            if name == "description" {
                let content = try meta.attr("content")
                return content
            }
        }
        return nil
    }

    func getCanonicalLink() throws -> String? {
        let links = try select("link")
        for link in links {
            let rel = try link.attr("rel")
            if rel == "canonical" {
                let content = try link.attr("href")
                return content
            }
        }
        return nil
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
        var metadata: Logger.Metadata = [
            "type": "\(pageBundle.contentType.id)",
            "slug": "\(pageBundle.slug)",
        ]

        do {
            let document: SwiftSoup.Document = try SwiftSoup.parse(html)

            if try document.getCanonicalLink() == nil {
                logger.warning(
                    "Canonical link not present",
                    metadata: metadata
                )
            }

            guard let title = try document.getTitle() else {
                throw Error.validation("Title not found")
            }

            if title.count > 65 {
                metadata["title"] = "`\(title)`"
                metadata["count"] = "\(title.count)"
                logger.warning(
                    "Title is too long, use maximum 65 characters.",
                    metadata: metadata
                )
            }
            else if title.count > 70 {
                metadata["title"] = "`\(title)`"
                metadata["count"] = "\(title.count)"
                logger.error(
                    "Title is way too long, use maximum 70 characters.",
                    metadata: metadata
                )
            }

            guard let description = try document.getDescription() else {
                throw Error.validation("Description not found")
            }

            if description.count < 50 {
                metadata["description"] = "`\(description)`"
                metadata["count"] = "\(description.count)"
                logger.warning(
                    "Description is too short, use minimum 50 characters.",
                    metadata: metadata
                )
            }
            if description.count > 160 {
                metadata["description"] = "`\(description)`"
                metadata["count"] = "\(description.count)"
                logger.warning(
                    "Description is too long, use maximum 160 characters.",
                    metadata: metadata
                )
            }
            else if description.count > 165 {
                metadata["description"] = "`\(description)`"
                metadata["count"] = "\(description.count)"
                logger.error(
                    "Description is way too long, use maximum 165 characters.",
                    metadata: metadata
                )
            }

            let headings = try document.select("h1")
            guard let h1tag = headings.first, headings.count == 1 else {
                throw Error.validation(
                    "Invalid number of H1 tags (missing or multiple)"
                )
            }
            let h1 = try h1tag.text()
            if h1.count > 80 {
                metadata["h1"] = "`\(h1)`"
                metadata["count"] = "\(h1.count)"
                logger.warning(
                    "Heading 1 should be 80 characters or less.",
                    metadata: metadata
                )
            }

            // check keyword
            if let keyword = pageBundle.frontMatter.string("keyword") {
                if !title.contains(keyword) {
                    metadata["title"] = "`\(title)`"
                    metadata["keyword"] = "`\(keyword)`"
                    logger.warning(
                        "Title does not contain keyword: `\(keyword)`.",
                        metadata: metadata
                    )
                }
                if !description.contains(keyword) {
                    metadata["description"] = "`\(description)`"
                    metadata["keyword"] = "`\(keyword)`"
                    logger.warning(
                        "Description does not contain keyword: `\(keyword)`.",
                        metadata: metadata
                    )
                }
                if !h1.contains(keyword) {
                    metadata["h1"] = "`\(h1)`"
                    metadata["keyword"] = "`\(keyword)`"
                    logger.warning(
                        "H1 does not contain keyword: `\(keyword)`.",
                        metadata: metadata
                    )
                }
            }
        }
        catch Exception.Error(_, let message) {
            logger.error(
                "\(message)",
                metadata: metadata
            )
        }
        catch {
            logger.error(
                "\(error.localizedDescription)",
                metadata: metadata
            )
        }
    }
}

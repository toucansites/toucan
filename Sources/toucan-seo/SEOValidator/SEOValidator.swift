//
//  SEOValidator.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2024. 10. 28..
//

import Foundation
import Logging
import SwiftSoup

extension SwiftSoup.Document {

    /// Selects the first matching element for a given CSS query.
    ///
    /// - Parameter query: A valid CSS selector.
    /// - Returns: The first matching element, or `nil` if none found.
    /// - Throws: Rethrows any `SwiftSoup` parsing or attribute access errors.
    public func selectFirst(_ query: String) throws -> Element? {
        try select(query).first()
    }

    /// Extracts the content of the `<title>` tag.
    ///
    /// - Returns: The page title as a `String`, or `nil` if not found.
    func getTitle() throws -> String? {
        try selectFirst("title")?.text()
    }

    /// Extracts the content of the meta description (`<meta name="description">`).
    ///
    /// - Returns: The value of the `content` attribute, or `nil` if not present.
    func getDescription() throws -> String? {
        let metas = try select("meta")
        for meta in metas {
            let name = try meta.attr("name")
            if name == "description" {
                return try meta.attr("content")
            }
        }
        return nil
    }

    /// Extracts the canonical link from the document (`<link rel="canonical">`).
    ///
    /// - Returns: The value of the `href` attribute, or `nil` if not found.
    /// - Throws: Rethrows any `SwiftSoup` parsing or attribute access errors.
    func getCanonicalLink() throws -> String? {
        let links = try select("link")
        for link in links {
            let rel = try link.attr("rel")
            if rel == "canonical" {
                return try link.attr("href")
            }
        }
        return nil
    }
}

/// Validates the SEO structure and quality of rendered HTML documents.
public struct SEOValidator {

    /// Possible validation errors detected during analysis.
    public enum Error: Swift.Error {
        case validation(String)
    }

    /// Logger used to report warnings and validation errors.
    let logger: Logger

    /// Initializes an SEOValidator with a given logger.
    ///
    /// - Parameter logger: A `Logger` instance for outputting diagnostics.
    public init(logger: Logger) {
        self.logger = logger
    }

    /// Performs SEO validation checks on the given HTML document.
    ///
    /// Checks include:
    /// - Canonical link presence
    /// - Title length and keyword presence
    /// - Meta description length and keyword presence
    /// - One and only one `<h1>` tag with a keyword
    ///
    /// - Parameters:
    ///   - html: The rendered HTML to analyze.
    ///   - pageBundle: The source bundle containing front matter and metadata.
    func validate(html: String, using pageBundle: PageBundle) {
        var metadata: Logger.Metadata = [
            "type": "\(pageBundle.contentType.id)",
            "slug": "\(pageBundle.slug)",
        ]

        do {
            let document: SwiftSoup.Document = try SwiftSoup.parse(html)

            // Check for canonical link
            if try document.getCanonicalLink() == nil {
                logger.warning("Canonical link not present", metadata: metadata)
            }

            // Validate title
            guard let title = try document.getTitle() else {
                throw Error.validation("Title not found")
            }
            if title.count > 70 {
                metadata["title"] = "`\(title)`"
                metadata["count"] = "\(title.count)"
                logger.warning(
                    "Title is way too long, use maximum 70 characters.",
                    metadata: metadata
                )
            }

            // Validate meta description
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

            // Validate H1
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

            // Keyword validation (optional)
            if let keyword = pageBundle.frontMatter.string("keyword") {
                metadata["title"] = nil
                metadata["description"] = nil
                metadata["h1"] = nil
                metadata["count"] = nil

                if !title.contains(keyword) {
                    metadata["title"] = "`\(title)`"
                    metadata["keyword"] = "`\(keyword)`"
                    logger.warning(
                        "Title does not contain keyword: `\(keyword)`",
                        metadata: metadata
                    )
                }

                if !description.contains(keyword) {
                    metadata["description"] = "`\(description)`"
                    metadata["keyword"] = "`\(keyword)`"
                    logger.warning(
                        "Description does not contain keyword: `\(keyword)`",
                        metadata: metadata
                    )
                }

                if !h1.contains(keyword) {
                    metadata["h1"] = "`\(h1)`"
                    metadata["keyword"] = "`\(keyword)`"
                    logger.warning(
                        "H1 does not contain keyword: `\(keyword)`",
                        metadata: metadata
                    )
                }
            }
        }
        catch Error.validation(let message) {
            logger.error("\(message)", metadata: metadata)
        }
        catch Exception.Error(_, let message) {
            logger.error("\(message)", metadata: metadata)
        }
        catch {
            logger.error("\(error.localizedDescription)", metadata: metadata)
        }
    }
}

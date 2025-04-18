//
//  ToucanTestSuite+Content.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 15..
//

import Testing
import Logging
import Foundation
import FileManagerKitTesting
import ToucanTesting
@testable import ToucanSDK

extension ToucanTestSuite {

    func content404() -> Directory {
        Directory("404") {
            File(
                "index.md",
                string: """
                    ---
                    type: not-found
                    title: "Not found"
                    description: "This page does not exists."
                    template: "pages.404"
                    ---

                    ## Not found

                    This page does not exists.

                    [Home](/)
                    """
            )
        }
    }

    func contentAbout() -> Directory {
        Directory("about") {
            File(
                "index.md",
                string: """
                    ---
                    slug: about
                    title: "About"
                    description: "This is the about page."
                    template: pages.default
                    ---

                    # About 

                    This is the about page.
                    """
            )
        }
    }

    func contentStyleCss() -> Directory {
        Directory("css") {
            File(
                "style.css",
                string: """
                    #home h1 {
                        text-transform: uppercase;
                    }
                    """
            )
        }
    }

    func contentHome() -> Directory {
        Directory("home") {
            File(
                "index.md",
                string: """
                    ---
                    slug: ""
                    title: "Home"
                    description: "Welcome to the home page."
                    template: pages.home
                    ---

                    # Home

                    Welcome to the home page.
                    """
            )
        }
    }

    func contentPost(index: Int) -> Directory {
        Directory("post\(index)") {
            File(
                "index.md",
                string: """
                    ---
                    type: post
                    title: Post title\(index)
                    description: Post description\(index)
                    publication: 2025-03-12 00:00:01
                    featured: false
                    ---

                    # Post\(index)

                    Contents of post\(index).
                    """
            )
        }
    }

    func contentRss() -> Directory {
        Directory("rss.xml") {
            File(
                "index.yml",
                string: """
                    type: rss
                    """
            )
        }
    }

    func contentSitemap() -> Directory {
        Directory("sitemap.xml") {
            File(
                "index.yml",
                string: """
                    type: sitemap
                    """
            )
        }
    }

}

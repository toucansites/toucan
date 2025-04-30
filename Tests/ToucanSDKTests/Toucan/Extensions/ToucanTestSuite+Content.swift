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

    func svg1() -> File {
        File(
            "test1.svg",
            string: """
                <svg width="800px" height="800px" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M6.46967 10.0303C6.17678 9.73744 6.17678 9.26256 6.46967 8.96967L11.4697 3.96967C11.7626 3.67678 12.2374 3.67678 12.5303 3.96967L17.5303 8.96967C17.8232 9.26256 17.8232 9.73744 17.5303 10.0303C17.2374 10.3232 16.7626 10.3232 16.4697 10.0303L12.75 6.31066L12.75 14.5C12.75 15.2133 12.9702 16.3 13.6087 17.1868C14.2196 18.0353 15.2444 18.75 17 18.75C17.4142 18.75 17.75 19.0858 17.75 19.5C17.75 19.9142 17.4142 20.25 17 20.25C14.7556 20.25 13.2804 19.298 12.3913 18.0632C11.5298 16.8667 11.25 15.4534 11.25 14.5L11.25 6.31066L7.53033 10.0303C7.23744 10.3232 6.76256 10.3232 6.46967 10.0303Z" fill="#1C274C"/>
                </svg>
                """
        )
    }

    func svg2() -> File {
        File(
            "test2.svg",
            string: """
                <svg width="800px" height="800px" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M6.46967 10.0303C6.17678 9.73744 6.17678 9.26256 6.46967 8.96967L11.4697 3.96967C11.7626 3.67678 12.2374 3.67678 12.5303 3.96967L17.5303 8.96967C17.8232 9.26256 17.8232 9.73744 17.5303 10.0303C17.2374 10.3232 16.7626 10.3232 16.4697 10.0303L12.75 6.31066L12.75 14.5C12.75 15.2133 12.9702 16.3 13.6087 17.1868C14.2196 18.0353 15.2444 18.75 17 18.75C17.4142 18.75 17.75 19.0858 17.75 19.5C17.75 19.9142 17.4142 20.25 17 20.25C14.7556 20.25 13.2804 19.298 12.3913 18.0632C11.5298 16.8667 11.25 15.4534 11.25 14.5L11.25 6.31066L7.53033 10.0303C7.23744 10.3232 6.76256 10.3232 6.46967 10.0303Z" fill="#1C274C"/>
                </svg>
                """
        )
    }

    func yaml1() -> File {
        File(
            "test1.yaml",
            string: """
                key1: value1
                key2: value2
                """
        )
    }

    func yaml2() -> File {
        File(
            "test2.yaml",
            string: """
                key3: value3
                key4: value4
                """
        )
    }

}

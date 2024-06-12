//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/05/2024.
//

struct Content {

    struct Blog {

        struct Author {
            let home: Page
            let contents: [Content.Author]

            func contentsBy(slugs: [String]) -> [Content.Author] {
                contents.filter {
                    slugs.map {
                        $0.lowercased()
                    }
                    .contains(
                        $0.slug.lowercased()
                    )
                }
            }
        }

        struct Tag {
            let home: Page
            let contents: [Content.Tag]

            func contentsBy(slugs: [String]) -> [Content.Tag] {
                contents.filter {
                    slugs.map {
                        $0.lowercased()
                    }
                    .contains(
                        $0.slug.lowercased()
                    )
                }
            }
        }

        struct Post {
            let home: Page
            let contents: [Content.Post]

            var sortedContents: [Content.Post] {
                contents.sorted { $0.publication > $1.publication }
            }

            func contentsBy(tagSlug: String) -> [Content.Post] {
                sortedContents.filter {
                    $0.tagSlugs
                        .map {
                            $0.lowercased()
                        }
                        .contains(
                            tagSlug.lowercased()
                        )
                }
            }

            func contentsBy(authorSlug: String) -> [Content.Post] {
                sortedContents.filter {
                    $0.authorSlugs
                        .map {
                            $0.lowercased()
                        }
                        .contains(
                            authorSlug.lowercased()
                        )
                }
            }
        }

        let home: Page
        let author: Author
        let tag: Tag
        let post: Post
    }

    struct Custom {
        let pages: [Page]
    }

    let config: Config

    let home: Page
    let notFound: Page
    let blog: Blog
    let custom: Custom
}

extension Content {

    var siteContents: [ContentInterface] {
        var result: [ContentInterface] = []
        result += [home]
        result += custom.pages
        result += [blog.post.home]
        result += blog.post.contents
        result += [blog.author.home]
        result += blog.author.contents
        result += [blog.tag.home]
        result += blog.tag.contents
        return result
    }
}

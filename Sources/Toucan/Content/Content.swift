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

            func contentsBy(ids: [String]) -> [Content.Author] {
                contents.filter {
                    ids.map {
                        $0.lowercased()
                    }
                    .contains(
                        $0.id.lowercased()
                    )
                }
            }
        }

        struct Tag {
            let home: Page
            let contents: [Content.Tag]

            func contentsBy(ids: [String]) -> [Content.Tag] {
                contents.filter {
                    ids.map {
                        $0.lowercased()
                    }
                    .contains(
                        $0.id.lowercased()
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

            func contentsBy(tagId: String) -> [Content.Post] {
                sortedContents.filter {
                    $0.tagIds
                        .map {
                            $0.lowercased()
                        }
                        .contains(
                            tagId.lowercased()
                        )
                }
            }
            func contentsBy(authorId: String) -> [Content.Post] {
                sortedContents.filter {
                    $0.authorIds
                        .map {
                            $0.lowercased()
                        }
                        .contains(
                            authorId.lowercased()
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

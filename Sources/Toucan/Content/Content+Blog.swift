//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 21/06/2024.
//

import Foundation

extension Site.Content {
    
    struct Blog {

        struct Post {
            let content: Source.Material
            let published: Date
            let tags: [String]
            let authors: [String]
            let featured: Bool
            
            init(
                content: Source.Material,
                config: Source.Config,
                dateFormatter: DateFormatter
            ) {
                self.content = content
                
                dateFormatter.dateFormat = config.site.dateFormat

                if
                    let rawDate = content.frontMatter["publication"] as? String,
                    let date = dateFormatter.date(from: rawDate)
                {
                    self.published = date
                }
                else {
                    self.published = Date()
                }
                
                let tags = content.frontMatter["tags"] as? [String] ?? []
                self.tags = tags.map { slug in
                    return slug.safeSlug(
                        prefix: config.contents.blog.tags.slugPrefix
                    )
                }
                
                let authors = content.frontMatter["authors"] as? [String] ?? []
                self.authors = authors.map { slug in
                    return slug.safeSlug(
                        prefix: config.contents.blog.authors.slugPrefix
                    )
                }
                
                self.featured = content.frontMatter["featured"] as? Bool ?? false
            }
            
            func context(site: Site) -> Context.Blog.Post {
                .init(
                    slug: content.slug,
                    permalink: site.permalink(content.slug),
                    title: content.title,
                    description: content.description,
                    imageUrl: content.imageUrl(),
                    // TODO: fix this
                    date: "",
                    tags: [],
                    authors: [],
                    readingTime: site.readingTime(content.markdown),
                    featured: featured,
                    userDefined: content.userDefined
                )
            }
        }

        struct Author {
            let content: Source.Material
            let posts: [Blog.Post]

            func context(site: Site) -> Context.Blog.Author {
                .init(
                    slug: content.slug,
                    permalink: site.permalink(content.slug),
                    title: content.title,
                    description: content.description,
                    imageUrl: content.imageUrl(),
                    // TODO: fix this
                    numberOfPosts: posts.count,
                    userDefined: content.userDefined,
                    markdown: site.render(content: content)
                )
            }
        }

        struct Tag {
            let content: Source.Material
            let posts: [Blog.Post]
            
            func context(site: Site) -> Context.Blog.Tag {
                .init(
                    slug: content.slug,
                    permalink: site.permalink(content.slug),
                    title: content.title,
                    description: content.description,
                    imageUrl: content.imageUrl(),
                    
                    numberOfPosts: posts.count,
                    userDefined: content.userDefined,
                    markdown: site.render(content: content)
                )
            }
        }

        let posts: [Post]
        let authors: [Author]
        let tags: [Tag]
        
        func sortedAuthors() -> [Author] {
            authors.sorted {
                $0.content.title.localizedCaseInsensitiveCompare($1.content.title) == .orderedAscending
            }
        }

        func sortedTags() -> [Tag] {
            tags.sorted {
                $0.content.title.localizedCaseInsensitiveCompare($1.content.title) == .orderedAscending
            }
        }

        func sortedPosts() -> [Post] {
            posts
                .sorted { $0.published > $1.published }
        }

        func featuredPosts() -> [Post] {
            posts
                .filter { $0.featured }
                .sorted { $0.published > $1.published }
        }
    }
    
}


//
//    func nextPost(for slug: String) -> PostState? {
//        let posts = content.blog.post.sortedContents
//
//        if let index = posts.firstIndex(where: { $0.slug == slug }) {
//            if index > 0 {
//                let post = posts[index - 1]
//                return postState(
//                    for: post,
//                    authors: content.blog.author.contentsBy(
//                        slugs: post.authorSlugs
//                    ),
//                    tags: content.blog.tag.contentsBy(
//                        slugs: post.tagSlugs
//                    )
//                )
//            }
//        }
//        return nil
//    }
//
//    func prevPost(for slug: String) -> PostState? {
//        let posts = content.blog.post.sortedContents
//
//        if let index = posts.firstIndex(where: { $0.slug == slug }) {
//            if index < posts.count - 1 {
//                let post = posts[index + 1]
//                return postState(
//                    for: post,
//                    authors: content.blog.author.contentsBy(
//                        slugs: post.authorSlugs
//                    ),
//                    tags: content.blog.tag.contentsBy(
//                        slugs: post.tagSlugs
//                    )
//                )
//            }
//        }
//        return nil
//    }
//
//    func relatedPosts(for slug: String) -> [PostState] {
//        var result: [PostState] = []
//
//        let posts = content.blog.post.sortedContents
//        if let index = posts.firstIndex(where: { $0.slug == slug }) {
//            let post = posts[index]
//            for tagSlug in post.tagSlugs {
//                result += content.blog.post.contentsBy(tagSlug: tagSlug)
//                    .filter { $0.slug != slug }
//                    .map {
//                        postState(
//                            for: $0,
//                            authors: content.blog.author.contentsBy(
//                                slugs: $0.authorSlugs
//                            ),
//                            tags: content.blog.tag.contentsBy(
//                                slugs: $0.tagSlugs
//                            )
//                        )
//                    }
//            }
//        }
//        return Array(result.shuffled().prefix(5))
//    }
//
//    func moreByPosts(for slug: String) -> [PostState] {
//        var result: [PostState] = []
//
//        let posts = content.blog.post.sortedContents
//        if let index = posts.firstIndex(where: { $0.slug == slug }) {
//            let post = posts[index]
//            for authorSlug in post.authorSlugs {
//                result += content.blog.post.contentsBy(authorSlug: authorSlug)
//                    .filter { $0.slug != slug }
//                    .map {
//                        postState(
//                            for: $0,
//                            authors: content.blog.author.contentsBy(
//                                slugs: $0.authorSlugs
//                            ),
//                            tags: content.blog.tag.contentsBy(
//                                slugs: $0.tagSlugs
//                            )
//                        )
//                    }
//            }
//        }
//        return Array(result.shuffled().prefix(5))
//    }

//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 21/06/2024.
//

import Foundation

extension Site.Contents {
    
    struct Blog {

        struct Post {
            let material: SourceMaterial
            let tags: [String]
            let authors: [String]
            let featured: Bool

            init(
                material: SourceMaterial,
                config: SourceConfig,
                dateFormatter: DateFormatter
            ) {
                self.material = material
                
                let tags = material.frontMatter["tags"] as? [String] ?? []
                self.tags = tags.map { slug in
                    return slug.safeSlug(
                        prefix: config.contents.blog.tags.slugPrefix
                    )
                }
                
                let authors = material.frontMatter["authors"] as? [String] ?? []
                self.authors = authors.map { slug in
                    return slug.safeSlug(
                        prefix: config.contents.blog.authors.slugPrefix
                    )
                }
                
                self.featured = material.frontMatter["featured"] as? Bool ?? false
            }
            
            func context(site: Site) -> Context.Blog.Post.Item {
                
                let tagReferences = site.contents.blog.tags
                    .filter { tags.contains($0.material.slug) }
                    .map { $0.ref(site: site) }
                
                let authorReferences = site.contents.blog.authors
                    .filter { authors.contains($0.material.slug) }
                    .map { $0.ref(site: site) }
                
                return .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl(),
                    readingTime: site.readingTime(material.markdown),
                    featured: featured,
                    date: site.dateFormatter.string(from: material.publication),
                    tags: tagReferences,
                    authors: authorReferences,
                    userDefined: site.contents.config.userDefined
                        .recursivelyMerged(with: material.userDefined)
                )
            }
            
            func ref(site: Site) -> Context.Blog.Post.Reference {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl(),
                    readingTime: site.readingTime(material.markdown),
                    featured: featured,
                    date: site.dateFormatter.string(from: material.publication),
                    userDefined: site.contents.config.userDefined
                        .recursivelyMerged(with: material.userDefined)
                )
            }
        }

        struct Author {
            let material: SourceMaterial
            let posts: [Blog.Post]

            func context(site: Site) -> Context.Blog.Author.Item {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl(),
                    numberOfPosts: posts.count
                )
            }
            
            func ref(site: Site) -> Context.Blog.Author.Reference {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl()
                )
            }
        }

        struct Tag {
            let material: SourceMaterial
            let posts: [Blog.Post]
            
            func context(site: Site) -> Context.Blog.Tag.Item {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl(),
                    
                    numberOfPosts: posts.count
                )
            }
            
            func ref(site: Site) -> Context.Blog.Tag.Reference {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl()
                )
            }
        }

        let posts: [Post]
        let authors: [Author]
        let tags: [Tag]
        
        init(
            posts: [Post],
            authors: [Author],
            tags: [Tag]
        ) {
            self.posts = posts
                .sorted {
                    $0.material.publication > $1.material.publication
                }

            self.authors = authors
                .sorted {
                    $0.material.title.localizedCaseInsensitiveCompare($1.material.title) == .orderedAscending
                }
            
            self.tags = tags
                .sorted {
                    $0.material.title.localizedCaseInsensitiveCompare($1.material.title) == .orderedAscending
                }
        }
        
        // MARK: - helpers

        func latestPosts(limit: Int = 10) -> [Post] {
            Array(posts.prefix(limit))
        }

        func featuredPosts(limit: Int = 6) -> [Post] {
            Array(
                posts
                    .filter { $0.featured }
                    .prefix(limit)
            )
        }
        
        func postIndex(for post: Post) -> Int? {
            posts.firstIndex(where: { $0.material.slug == post.material.slug })
        }
        
        func prevPost(_ post: Post) -> Post? {
            guard
                let index = postIndex(for: post),
                index < posts.count - 1
            else {
                return nil
            }
            return posts[index + 1]
        }
        
        func nextPost(_ post: Post) -> Post? {
            guard 
                let index = postIndex(for: post),
                index > 0
            else {
                return nil
            }
            return posts[index - 1]
        }
        
        /// posts from the same tags
        func related(post: Post, limit: Int = 4) -> [Post] {
            var result: [Post] = []
            for tagSlug in post.tags {
                result += posts
                    .filter { $0.tags.contains(tagSlug) }
                    .filter { $0.material.slug != post.material.slug }
            }
            return Array(
                result
                    .shuffled()
                    .prefix(limit)
            )
        }
        
        /// posts from the same author
        func more(post: Post, limit: Int = 4) -> [Post] {
            var result: [Post] = []
            for authorSlug in post.authors {
                result += posts
                    .filter { $0.authors.contains(authorSlug) }
                    .filter { $0.material.slug != post.material.slug }
            }
            return Array(
                result
                    .shuffled()
                    .prefix(limit)
            )
        }
    }
}

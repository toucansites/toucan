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
            let published: Date
            let tags: [String]
            let authors: [String]
            let featured: Bool

            init(
                material: SourceMaterial,
                config: SourceConfig,
                dateFormatter: DateFormatter
            ) {
                self.material = material
                
                dateFormatter.dateFormat = config.site.dateFormat

                if
                    let rawDate = material.frontMatter["publication"] as? String,
                    let date = dateFormatter.date(from: rawDate)
                {
                    self.published = date
                }
                else {
                    self.published = Date()
                }
                
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
                    date: site.dateFormatter.string(from: published),
                    tags: tagReferences,
                    authors: authorReferences
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
                    date: site.dateFormatter.string(from: published)
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
        
        // MARK: - helpers

        func sortedAuthors() -> [Author] {
            authors.sorted {
                $0.material.title.localizedCaseInsensitiveCompare($1.material.title) == .orderedAscending
            }
        }

        func sortedTags() -> [Tag] {
            tags.sorted {
                $0.material.title.localizedCaseInsensitiveCompare($1.material.title) == .orderedAscending
            }
        }

        func latestPosts(limit: Int = 10) -> [Post] {
            Array(
                sortedPosts()
                    .prefix(limit)
            )
        }
        
        func sortedPosts() -> [Post] {
            posts
                .sorted { $0.published > $1.published }
        }

        func featuredPosts(limit: Int = 5) -> [Post] {
            Array(
                posts
                    .filter { $0.featured }
                    .sorted { $0.published > $1.published }
                    .prefix(limit)
            )
        }
        
        func prevPost(_ post: Post) -> Post? {
            let posts = sortedPosts()
            guard
                let index = posts.firstIndex(where: { $0.material.slug == post.material.slug }),
                index < posts.count - 1
            else {
                return nil
            }
            return posts[index + 1]
        }
        
        func nextPost(_ post: Post) -> Post? {
            let posts = sortedPosts()
            guard 
                let index = posts.firstIndex(where: { $0.material.slug == post.material.slug }),
                index > 0
            else {
                return nil
            }
            return posts[index - 1]
        }
        
        /// posts from the same tags
        func related(post: Post, limit: Int = 5) -> [Post] {
            var result: [Post] = []
            let posts = sortedPosts()
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
        func more(post: Post, limit: Int = 5) -> [Post] {
            var result: [Post] = []
            let posts = sortedPosts()
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

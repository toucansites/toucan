//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation

extension Site.Contents {
    
    struct Docs {
        
        struct Category {
            let material: SourceMaterial
            let order: Int
            
            init(
                material: SourceMaterial
            ) {
                self.material = material
                self.order = material.frontMatter["order"] as? Int ?? 0
            }
            
            func ref(
                site: Site
            ) -> Context.Docs.Category.Reference {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl(),
                    date: site.dateFormatter.string(from: material.lastModification)
                )
            }
            
            func context(
                site: Site,
                guides: [Site.Contents.Docs.Guide]
            ) -> Context.Docs.Category.Item {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl(),
                    date: site.dateFormatter.string(from: material.lastModification),
                    guides: guides.map { $0.ref(site: site) }
                )
            }
        }

        struct Guide {
            let material: SourceMaterial
            let order: Int
            let category: String
            
            init(
                material: SourceMaterial,
                config: SourceConfig
            ) {
                self.material = material
                self.order = material.frontMatter["order"] as? Int ?? 0
                guard let c = material.frontMatter["category"] as? String else {
                    fatalError("Missing docs category for `\(material.slug)`.")
                }
                self.category = c.safeSlug(
                    prefix: config.contents.docs.categories.slugPrefix
                )
            }
            
            func ref(
                site: Site
            ) -> Context.Docs.Guide.Reference {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl(),
                    date: site.dateFormatter.string(from: material.lastModification),
                    category: site.contents.docs.category(for: category).map { $0.ref(site: site) }
                )
            }
            
            func context(
                site: Site,
                category: Context.Docs.Category.Reference,
                prev: Context.Docs.Guide.Reference?,
                next: Context.Docs.Guide.Reference?
            ) -> Context.Docs.Guide.Item {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl(),
                    date: site.dateFormatter.string(from: material.lastModification),
                    category: category,
                    prev: prev,
                    next: next
                )
            }
        }
        
        let categories: [Category]
        let guides: [Guide]
        
        init(
            categories: [Category],
            guides: [Guide]
        ) {
            self.categories = categories.sorted { $0.order < $1.order }
            self.guides = guides.sorted { $0.order < $1.order }
        }
        
        func guides(category: Category) -> [Guide] {
            guides.filter { $0.category == category.material.slug }
        }
        
        func category(for category: String) -> Category? {
            categories.first { $0.material.slug == category }
        }
        
        func category(for guide: Guide) -> Category? {
            categories.first { $0.material.slug == guide.category }
        }
        
        func guides(category: String) -> [Guide] {
            guides.filter { $0.category == category }
        }
        
        func guideIndex(for guide: Guide, in guides: [Guide]) -> Int? {
            guides.firstIndex(where: { $0.material.slug == guide.material.slug })
        }
        
        func categoryIndex(for category: String) -> Int? {
            categories.firstIndex(where: { $0.material.slug == category })
        }
        
        func prev(_ guide: Guide) -> Guide? {
            let guides = guides(category: guide.category)
            guard
                let index = guideIndex(for: guide, in: guides),
                index > 0
            else {
                if
                    let categoryIndex = categoryIndex(for: guide.category),
                    categoryIndex > 0
                {
                    let nextIndex = categoryIndex - 1
                    let category = categories[nextIndex]
                    return self.guides(category: category).last
                }
                return nil
            }
            return guides[index - 1]
        }

        func next(_ guide: Guide) -> Guide? {
            let guides = guides(category: guide.category)
            guard
                let index = guideIndex(for: guide, in: guides),
                index < guides.count - 1
            else {
                if 
                    let categoryIndex = categoryIndex(for: guide.category),
                    categoryIndex < categories.count - 1
                {
                    let nextIndex = categoryIndex + 1
                    let category = categories[nextIndex]
                    return self.guides(category: category).first
                }
                return nil
            }
            return guides[index + 1]
        }
    }

}

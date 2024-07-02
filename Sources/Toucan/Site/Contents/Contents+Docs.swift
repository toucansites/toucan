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
            
            func context(
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
                    guides: guides.map { $0.context(site: site) }
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
                    fatalError("Missing docs category")
                }
                self.category = c.safeSlug(
                    prefix: config.contents.docs.categories.slugPrefix
                )
            }
            
            func context(
                site: Site
            ) -> Context.Docs.Guide.Reference {
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
        
        func category(for guide: Guide) -> Category? {
            categories.first { $0.material.slug == guide.category }
        }
        
        func prev(_ guide: Guide) -> Guide? {
            let guides = guides.filter { $0.category == guide.category }
            guard
                let index = guides.firstIndex(where: { $0.material.slug == guide.material.slug }),
                index > 0
            else {
                return nil
            }
            return guides[index - 1]
        }

        func next(_ guide: Guide) -> Guide? {
            let guides = guides.filter { $0.category == guide.category }
            guard
                let index = guides.firstIndex(where: { $0.material.slug == guide.material.slug }),
                index < guides.count - 1
            else {
                return nil
            }
            return guides[index + 1]
        }
    }

}

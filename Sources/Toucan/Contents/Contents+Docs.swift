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
            
            func context(site: Site) -> Context.Docs.Category.Link {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl(),
                    date: site.dateFormatter.string(from: material.lastModification),
                    guides: []
                )
            }
            
            func context(site: Site) -> Context.Docs.Category.Item {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl(),
                    date: site.dateFormatter.string(from: material.lastModification),
                    guides: [],
                    userDefined: material.userDefined
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
            
            func context(site: Site) -> Context.Docs.Guide.Link {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl(),
                    date: site.dateFormatter.string(from: material.lastModification)
                )
            }
            
            func context(site: Site) -> Context.Docs.Guide.Item {
                .init(
                    slug: material.slug,
                    permalink: site.permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl(),
                    date: site.dateFormatter.string(from: material.lastModification),
                    category: .init(
                        slug: "",
                        permalink: "",
                        title: "",
                        description: "",
                        imageUrl: nil,
                        date: "",
                        guides: []
                    ),
                    userDefined: material.userDefined
                )
            }
        }
        
        let categories: [Category]
        let guides: [Guide]
        
        var sortedCategories: [Category] {
            categories.sorted { $0.order < $1.order }
        }
        
        var sortedGuides: [Guide] {
            guides.sorted { $0.order < $1.order }
        }
        
        func guides(category: Category) -> [Guide] {
            sortedGuides.filter { $0.category == category.material.slug }
        }
        
        func category(for guide: Guide) -> Category? {
            categories.first { $0.material.slug == guide.category }
        }
    }

}

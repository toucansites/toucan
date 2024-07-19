////
////  File.swift
////  
////
////  Created by Tibor Bodecs on 27/06/2024.
////
//
//import Foundation
//
//extension Site.Contents {
//    
//    struct Pages {
//        
//        struct Custom {
//
//            let material: SourceMaterial
//            let order: Int
//            
//            init(
//                material: SourceMaterial
//            ) {
//                self.material = material
//                self.order = material.frontMatter["order"] as? Int ?? 0
//            }
//
//            func context(site: Site) -> Context.Pages.Item {
//                .init(
//                    slug: material.slug,
//                    permalink: site.permalink(material.slug),
//                    title: material.title,
//                    description: material.description,
//                    imageUrl: material.imageUrl()
//                )
//            }
//        }
//
//        let custom: [Custom]
//
//        init(custom: [Custom]) {
//            self.custom = custom.sorted { $0.order < $1.order }
//        }
//    }
//    
//    
//}

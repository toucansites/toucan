//
//  renderer.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//



struct Renderer {
    
    let id: String
    let config: RendererConfig
    let excludedTypes: [String] // e.g. exclude pages from json

    func render(
        contentBundles: [ContentBundle]
    ) {
        
        let cbs = contentBundles.map { cb in
            var cb = cb
            cb.pageBundles = cb.pageBundles.map { cb.loadFields(pageBundle: $0) }
            return cb
        }

        for contentBundle in cbs {
            for pageBundle in contentBundle.pageBundles {
                print(pageBundle.properties)
            }
        }
        
        
        return;
        
        
        var context: [String: Any] = [:]
        
        for (key, query) in config.queries {
            context[key] = []

            guard let bundle = contentBundles.first(where: { $0.contentType.id == query.contentType }) else {
                continue
            }

            if let filter = query.filter {
                switch filter {
                case let .field(key, op, value):
                    
                    let prop = bundle.contentType.properties.first { $0.key == key }!
                    for pageBundle in bundle.pageBundles {
                        let rawValue = pageBundle.frontMatter[key]
                    }

                    print(key, op, value)
                case .and(_):
                    break
                case .or(_):
                    break
                }
            }

//            print(bundle.pageBundles)
            // TODO: proper query
            context[key] = bundle.pageBundles.map { $0.frontMatter["id"]! }
        }
        
        return;
//        let rendererScopes = Set(scopes.map { id + "." + $0 })

        for contentBundle in contentBundles {

            
//            let contextDefinition = contentBundle.contentType.context
            
            for pageBundle in contentBundle.pageBundles {

                for property in contentBundle.contentType.properties {
//                    let propertyScopes = Set(property.scopes.map(\.renderer))
//                    guard !rendererScopes.intersection(propertyScopes).isEmpty else {
//                        print("property `\(property.key)` is not in the scope")
//                        continue
//                    }
                }

                print()
            }
            print("---")
        }
        
        print(context)
    }
}



//extension [PageBundle] {
//    
//    func list(
//        contentType: ContentType,
//        sortKey: String?,
//        order: Order
//    ) -> [PageBundle] {
//        self
//    }
//}

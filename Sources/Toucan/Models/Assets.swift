//
//  File.swift
//
//
//  Created by Tibor Bodecs on 17/05/2024.
//

struct Assets {

    enum Variant {
        case light
        case dark
    }

    // TODO: remove site dependency, return slug only...
    private let site: Site
    private let assets: [String: String]

    init(
        _ site: Site,
        _ assets: [String: String]
    ) {
        self.site = site
        self.assets = assets
    }

    func exists(_ id: String) -> Bool {
        assets[id] != nil
    }

    func url(
        _ id: String?,
        for type: ContentType,
        variant: Variant = .light
    ) -> String? {
        guard let id, !id.isEmpty else {
            return nil
        }
        if id.hasPrefix("./") {
            // TODO: handle this better...
            var key: String
            switch variant {
            case .light:
                key = id
            case .dark:
                var items = id.split(separator: ".")
                items.insert("~dark", at: items.count - 1)
                key =
                    "."
                    + items
                    .joined(separator: ".")
                    .replacingOccurrences(
                        of: ".~dark",
                        with: "~dark"
                    )
            }

            key = key.replacingOccurrences(
                of: "./",
                with: "./\(type.rawValue)s/"
            )

            if let slug = assets[key] {
                return site.permalink(slug)
            }
            return nil
        }
        return id
    }
}

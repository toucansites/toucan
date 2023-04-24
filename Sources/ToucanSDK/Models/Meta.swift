import Foundation

struct Meta {

    let site: String
    let baseUrl: String
    let slug: String
    let title: String
    let description: String
    let image: String

    var templateVariables: [String: String] {
        [
            "site": site,
            "baseUrl": baseUrl,
            "slug": slug + "/",
            "title": title,
            "description": description,
            "image": image,
        ]
    }

    var permalink: String {
        baseUrl + slug + "/"
    }
}

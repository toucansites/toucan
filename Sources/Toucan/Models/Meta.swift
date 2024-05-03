import Foundation

struct Meta {

    let site: String
    let baseUrl: String
    let slug: String
    let title: String
    let description: String
    let image: String
    let language: String

    var templateVariables: [String: String] {
        [
            "site": site,
            "baseUrl": baseUrl,
            "slug": slug,
            "permalink": permalink,
            "title": title,
            "description": description,
            "image": image,
            "language": language,
        ]
    }

    var permalink: String {
        var permalink = baseUrl + slug
        if !permalink.hasSuffix("/") {
            permalink += "/"
        }
        return permalink
    }
}
